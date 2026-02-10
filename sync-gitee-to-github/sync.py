#!/bin/bash
import os
import sys
import time
import requests
import threading

programPath = os.path.split(os.path.realpath(__file__))[0]  # 返回 string
dataHeaders = {
    "accept": "application/json"
}
pullUrl = "https://gitee.com/GXDE-OS/"
pushUrl = [
    "https://@USER@:@PASS@@github.com/GXDE-OS/",
    "https://@USER@:@PASS@@gitcode.com/GXDE-OS/",
    "https://@USER@:@PASS@@atomgit.com/GXDE-OS/"
]

if (len(sys.argv) < 1 + len(pushUrl) * 2):
    print(f"请输入用于推送的账户和密码（需要 {len(pushUrl)} 组以推送不同的平台，提供顺序如下）")
    for i in pushUrl:
        print(f"    {i}")
    exit(1)

# 读取参数
userName = []
password = []
for i in range(1, len(sys.argv)):
    # 输入账户
    if (i % 2 == 1):
        userName.append(sys.argv[i])
    # 输入密码
    if (i % 2 == 0):
        password.append(sys.argv[i])

def sync(i):
    global thread
    # 拉取代码进行同步
    if (not os.path.exists(f"{programPath}/git-clone")):
        os.makedirs(f"{programPath}/git-clone")
    print(f"======================> {pullUrl}/{i}")
    os.system(f"cd '{programPath}/git-clone' ; git clone --bare '{pullUrl}/{i}'")
    # 推送
    for j in range(len(pushUrl)):
        # git remote set-url origin 
        gitUrl = pushUrl[j].replace("@USER@", userName[j]).replace("@PASS@", password[j]) + "/" + i
        os.system(f"cd '{programPath}/git-clone/{i}.git' ; git remote set-url origin '{gitUrl}'")
        os.system(f"cd '{programPath}/git-clone/{i}.git' ; git push --mirror")
    # 移除临时文件
    os.system(f"rm -rf '{programPath}/git-clone/{i}.git'")
    thread -= 1

data = requests.get("https://api.github.com/users/GXDE-OS/repos", headers=dataHeaders).json()
repoList = []
# 获取仓库列表
for i in data:
    repoList.append(i["name"])
# 多线程处理以提升速度
thread = 0
threadMax = 32
for i in repoList:
    while True:
        time.sleep(0.1)
        if (thread < threadMax):
            threading.Thread(target=sync, args=[i]).start()
            thread += 1
            break

