#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
将 GitHub 上的 GXDE-OS 组织仓库镜像同步到 Gitee（GXDE-OS 组织）。

用法:
    python3 sync.py <github用户名> <githubToken> <gitee用户名> <gitee密码或Token>

流程:
    1. 通过 GitHub REST API（Bearer token 认证）分页获取 GXDE-OS 组织下的全部仓库
    2. 多线程 clone --bare 拉取 GitHub 仓库
    3. 逐个 push --mirror 推送到 Gitee，失败自动重试并在结束时汇总报告

注意:
    - Gitee 侧的同名仓库需要预先存在，push --mirror 会覆盖其分支与标签
    - GitHub 只接受 Personal Access Token 作为密码（需具备组织仓库的读取权限）
    - GitHub 匿名 API 只有 60 次/小时且按出口 IP 共享，故不做匿名回退：
      token 缺失或失效时直接报错退出，避免静默同步到不完整的仓库列表
"""
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

programPath = os.path.split(os.path.realpath(__file__))[0]
cloneDir = os.path.join(programPath, "git-clone")
orgName = "GXDE-OS"
perPage = 100
threadMax = 8
retryMax = 3
gitTimeout = 600
# git 自带低速检测：连续 60 秒低于 1KB/s 即中止，避免跨境网络长时间挂起
gitOpts = ["git", "-c", "http.lowSpeedLimit=1000", "-c", "http.lowSpeedTime=60"]


def log(msg):
    # Actions 下 stdout 默认全缓冲，必须 flush 才能实时看到进度
    print(msg, flush=True)


def usage():
    log("用法: python3 sync.py <github用户名> <githubToken> <gitee用户名> <gitee密码或Token>")
    sys.exit(1)


def apiGet(path, params, token):
    """调用 GitHub REST API 的单个请求，失败时给出可读的状态码与响应体"""
    params["per_page"] = str(perPage)
    url = "https://api.github.com" + path + "?" + urllib.parse.urlencode(params)
    headers = {
        "User-Agent": "GXDE-Sync/1.0",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "Authorization": "Bearer " + token,
    }
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")[:500]
        raise RuntimeError(f"HTTP {e.code} {body}") from e
    except urllib.error.URLError as e:
        raise RuntimeError(f"网络错误: {e.reason}") from e


def getGithubRepos(token):
    """分页获取 GitHub 组织下全部仓库的 name（即 URL 路径中的仓库名）"""
    repoList = []
    page = 1
    while True:
        data = apiGet(f"/orgs/{orgName}/repos", {"page": str(page), "type": "all"}, token)
        if not isinstance(data, list):
            # 例如限流时返回 {"message": "API rate limit exceeded ..."}
            raise RuntimeError(f"返回内容不是仓库列表: {str(data)[:500]}")
        if not data:
            break
        repoList.extend([i["name"] for i in data])
        if len(data) < perPage:
            break
        page += 1
    return repoList


def runGit(args, timeout=gitTimeout):
    """执行 git 命令；超时后终止子进程并返回失败结果，避免 job 永久挂起"""
    try:
        return subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, timeout=timeout)
    except subprocess.TimeoutExpired as e:
        out = e.output or ""
        if isinstance(out, bytes):
            out = out.decode("utf-8", "replace")
        return subprocess.CompletedProcess(args, 1, out + f"\n[超时] 超过 {timeout} 秒已终止")


def hideSecrets(out, pullUrl, pushUrl):
    """git 报错会带上含账号密码的 URL，打印前先脱敏"""
    return (out or "").replace(pullUrl, "<github>/").replace(pushUrl, "<gitee>/")


def syncRepo(name, pullUrl, pushUrl):
    repoDir = os.path.join(cloneDir, name + ".git")
    try:
        # 1. 从 GitHub clone --bare（重试 retryMax 次）
        ok = False
        for attempt in range(1, retryMax + 1):
            shutil.rmtree(repoDir, ignore_errors=True)  # 清掉上次失败的残留目录
            log(f"[....] clone ({attempt}/{retryMax}): {name}")
            result = runGit(gitOpts + ["clone", "--bare", pullUrl + name, repoDir])
            if result.returncode == 0:
                ok = True
                break
            log(f"[WARN] clone 失败 ({attempt}/{retryMax}): {name}\n"
                f"{hideSecrets(result.stdout, pullUrl, pushUrl)}")
            time.sleep(5)
        if not ok:
            log(f"[FAIL] clone 放弃: {name}")
            return False

        # 2. push --mirror 到 Gitee（重试 retryMax 次）
        ok = False
        for attempt in range(1, retryMax + 1):
            log(f"[....] push  ({attempt}/{retryMax}): {name}")
            result = runGit(gitOpts + ["-C", repoDir, "push", "--mirror", pushUrl + name])
            if result.returncode == 0:
                ok = True
                break
            log(f"[WARN] push 失败 ({attempt}/{retryMax}): {name}\n"
                f"{hideSecrets(result.stdout, pullUrl, pushUrl)}")
            time.sleep(5)
        if not ok:
            log(f"[FAIL] push 放弃: {name}")
            return False

        log(f"[ OK ] 同步完成: {name}")
        return True
    finally:
        shutil.rmtree(repoDir, ignore_errors=True)


def main():
    os.environ["GIT_TERMINAL_PROMPT"] = "0"  # 凭证失效时不要等交互式输入

    if len(sys.argv) < 5:
        usage()
    githubUser, githubToken, giteeUser, giteeToken = sys.argv[1:5]
    for label, value in (("github用户名", githubUser), ("githubToken", githubToken),
                         ("gitee用户名", giteeUser), ("gitee密码或Token", giteeToken)):
        if not value:
            log(f"[FAIL] 参数 {label} 为空，请检查 workflow 中的 secrets 配置")
            sys.exit(1)

    githubAuth = urllib.parse.quote(githubUser, safe="") + ":" + urllib.parse.quote(githubToken, safe="")
    giteeAuth = urllib.parse.quote(giteeUser, safe="") + ":" + urllib.parse.quote(giteeToken, safe="")
    pullUrl = f"https://{githubAuth}@github.com/{orgName}/"
    pushUrl = f"https://{giteeAuth}@gitee.com/{orgName}/"

    os.makedirs(cloneDir, exist_ok=True)

    try:
        repoList = getGithubRepos(githubToken)
    except Exception as e:
        log(f"[FAIL] 获取 GitHub 仓库列表失败: {e}")
        log("       请确认 GITHUBTOKEN 有效未过期，且对 GXDE-OS 组织有读取权限")
        sys.exit(1)
    log(f"共获取到 {len(repoList)} 个仓库")
    if not repoList:
        log("[FAIL] 仓库列表为空，退出")
        sys.exit(1)

    failed = []
    with ThreadPoolExecutor(max_workers=threadMax) as pool:
        futures = {pool.submit(syncRepo, n, pullUrl, pushUrl): n for n in repoList}
        for future in as_completed(futures):
            name = futures[future]
            try:
                ok = future.result()
            except Exception as e:
                log(f"[FAIL] 同步异常: {name}: {e}")
                ok = False
            if not ok:
                failed.append(name)

    log("=" * 50)
    log(f"同步完成: 成功 {len(repoList) - len(failed)} / {len(repoList)}")
    if failed:
        log("以下仓库同步失败:")
        for name in failed:
            log("  - " + name)
        sys.exit(1)


if __name__ == "__main__":
    main()
