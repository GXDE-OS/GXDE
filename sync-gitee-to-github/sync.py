#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
将 Gitee 上的 GXDE-OS 组织仓库镜像同步到 GitHub（GXDE-OS 组织）。

用法:
    python3 sync.py <gitee用户名> <gitee密码或Token> <github用户名> <githubToken>

流程:
    1. 通过 Gitee API v5 分页获取 GXDE-OS 组织下的全部仓库列表（带 token 失败时回退匿名）
    2. 多线程 clone --bare 拉取 Gitee 仓库
    3. 逐个 push --mirror 推送到 GitHub，失败自动重试并在结束时汇总报告
"""
import json
import os
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

programPath = os.path.split(os.path.realpath(__file__))[0]
cloneDir = os.path.join(programPath, "git-clone")
orgName = "GXDE-OS"
perPage = 100
threadMax = 8


def usage():
    print("用法: python3 sync.py <gitee用户名> <gitee密码或Token> <github用户名> <githubToken>")
    sys.exit(1)


def apiGet(path, params):
    """调用 Gitee API v5 的单个请求"""
    params["per_page"] = str(perPage)
    url = "https://gitee.com/api/v5" + path + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": "GXDE-Sync/1.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def getGiteeRepos(token):
    """分页获取 Gitee 组织下全部仓库的 path（URL 安全路径）

    Gitee API 返回的 name 是仓库别名（可能含大写、中文或括号，如
    "CTranslate2"），不能直接用作 clone URL 的路径组件；path 才是 URL
    安全的仓库路径（如 "ctranslate2"），用它拼接 clone/push URL 才合法。
    """
    repoList = []
    page = 1
    while True:
        params = {"page": str(page)}
        if token:
            params["access_token"] = token
        data = apiGet(f"/orgs/{orgName}/repos", params)
        if not isinstance(data, list) or len(data) == 0:
            break
        repoList.extend([i["path"] for i in data])
        page += 1
    return repoList


def runGit(args, cwd=None):
    return subprocess.run(args, cwd=cwd, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True)


def syncRepo(name, pullUrl, pushUrl):
    repoDir = os.path.join(cloneDir, name + ".git")
    try:
        # 1. 从 Gitee clone --bare（重试 3 次）
        ok = False
        lastOut = ""
        for attempt in range(3):
            result = runGit(["git", "clone", "--bare", pullUrl + name, repoDir])
            if result.returncode == 0:
                ok = True
                break
            lastOut = result.stdout
            time.sleep(5)
        if not ok:
            print(f"[FAIL] clone 失败: {name}\n{lastOut}")
            return False

        # 2. push --mirror 到 GitHub（重试 3 次）
        ok = False
        lastOut = ""
        for attempt in range(3):
            result = runGit(["git", "-C", repoDir, "push", "--mirror", pushUrl + name])
            if result.returncode == 0:
                ok = True
                break
            lastOut = result.stdout
            time.sleep(5)
        if not ok:
            print(f"[FAIL] push 失败: {name}\n{lastOut}")
            return False

        print(f"[ OK ] 同步完成: {name}")
        return True
    finally:
        # 清理临时目录
        runGit(["rm", "-rf", repoDir])


def main():
    if len(sys.argv) < 5:
        usage()
    giteeUser, giteeToken = sys.argv[1], sys.argv[2]
    githubUser, githubToken = sys.argv[3], sys.argv[4]

    pullUrl = f"https://{urllib.parse.quote(giteeUser)}:{urllib.parse.quote(giteeToken)}@gitee.com/{orgName}/"
    pushUrl = f"https://{urllib.parse.quote(githubUser)}:{urllib.parse.quote(githubToken)}@github.com/{orgName}/"

    os.makedirs(cloneDir, exist_ok=True)

    # 获取仓库列表：优先带 token，失败则回退到匿名（仅公开仓库）
    try:
        repoList = getGiteeRepos(giteeToken)
    except Exception:
        repoList = getGiteeRepos("")
    print(f"共获取到 {len(repoList)} 个仓库")
    if not repoList:
        print("未能获取仓库列表，退出")
        sys.exit(1)

    failed = []
    with ThreadPoolExecutor(max_workers=threadMax) as pool:
        futures = {pool.submit(syncRepo, n, pullUrl, pushUrl): n for n in repoList}
        for future in as_completed(futures):
            if not future.result():
                failed.append(futures[future])

    print("=" * 50)
    print(f"同步完成: 成功 {len(repoList) - len(failed)} / {len(repoList)}")
    if failed:
        print("以下仓库同步失败:")
        for name in failed:
            print("  -", name)
        sys.exit(1)


if __name__ == "__main__":
    main()
