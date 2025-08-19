## 如何解决 `git` 时的鉴权失败问题

---

#### 诊断 SSH 连接问题

首先，让我们测试一下到 GitHub 的 SSH 连接是否通畅。在终端中运行以下命令：

```bash
ssh -T git@github.com
```

根据这个命令的输出，会有以下几种情况：

- **情况 A：看到成功欢迎信息 (最好！)**

  ```
  Hi Alipebt! You've successfully authenticated, but GitHub does not provide shell access.
  ```

  如果看到这个，说明 SSH 配置完全正确！`git push` 失败可能是其他临时问题，请直接跳到第 4 步。

- **情况 B：看到权限被拒绝 (Permission denied / publickey)**

  ```
  Permission denied (publickey).
  ```

  或者

  ```
  git@github.com: Permission denied (publickey).
  ```

  这表示 GitHub 拒绝了你的连接，因为没有识别到有效的公钥。这是最常见的情况，请继续第 2 步。

- **情况 C：看到“ authenticity of host can't be established ”**

  ```
  The authenticity of host 'github.com (IP.ADDRESS)' can't be established.
  ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/rZkW+2C4P2G1DG4VIF098.
  Are you sure you want to continue connecting (yes/no/[fingerprint])?
  ```

  这是正常的，输入 `yes` 然后按回车。之后应该会变成情况 A 或情况 B。

  ---

```shell
> git push
Username for 'https://github.com': Alipebt
Password for 'https://Alipebt@github.com': 
remote: invalid credentials
致命错误：'https://github.com/Alipebt/Notes.git/' 鉴权失败

> git push
Username for 'https://github.com': Alipebt
Password for 'https://Alipebt@github.com': 
remote: Invalid username or token. Password authentication is not supported for Git operations.
致命错误：'https://github.com/Alipebt/Notes.git/' 鉴权失败
```



GitHub 已经移除了对单纯使用账户密码进行 Git 操作的支持，你必须使用个人访问令牌（Personal Access Token, PAT） 或者 SSH 密钥来验证身份。

错误信息 `Password authentication is not supported` 明确指出了这一点。



个人访问令牌验证`http`下进行`git`操作

SSH 密钥验证`ssh`下进行`git`操作

---

### 方案一：使用个人访问令牌（PAT）代替密码 

这种方法是在你当前使用的 HTTPS 地址基础上，只需修改密码即可。

#### 1. 生成一个新的个人访问令牌（PAT）

1. 登录你的 GitHub 账户。
2. 点击右上角你的头像，进入 **Settings（设置）**。
3. 在左侧边栏最底部，找到并点击 **Developer settings（开发者设置）**。
4. 点击 **Personal access tokens（个人访问令牌）** -> **Tokens (classic)（令牌（经典））**。
5. 点击 **Generate new token（生成新令牌）** -> **Generate new token (classic)（生成新令牌（经典））**。
6. 给你的令牌起一个描述性的名称（例如 `My-Laptop` 或 `Work-Desktop`）。
7. 选择过期时间（Expiration）：为了安全，建议设置一个有效期（如90天）。你也可以选择 `No expiration（永不过期）`，但请妥善保管。
8. 选择权限（Scope）：为了完成 `git push` 操作，你至少需要勾选 `repo` 权限。它会自动包含所有仓库操作的全部权限。如果你还需要其他操作（如删除仓库），可以勾选 `delete_repo` 等，但通常 `repo` 就足够了。
9. 滚动到页面最下方，点击 **Generate token（生成令牌）**。

⚠ **重要警告：** 立即复制生成的那串字符！ 这串字符（例如 `ghp_16a7x42z...`）只会显示这一次，关掉页面后就再也看不到了。把它当作你的新密码来保管。

#### 2. 使用令牌进行 Git 操作

现在，回到你的命令行再次尝试 `git push`：

```bash
> git push
Username for 'https://github.com': Alipebt  # 这里仍然输入你的GitHub用户名
Password for 'https://Alipebt@github.com':  # 这里！！！粘贴你刚才复制的令牌，而不是你的GitHub登录密码
```

输入令牌后，推送就应该能成功了。



### 方案二：使用 SSH 密钥

这种方法需要生成一对密钥（公钥和私钥），将公钥上传到 GitHub，然后修改你本地仓库的远程地址为 SSH 格式。

#### 1. 检查并生成 SSH 密钥

首先，检查是否已有 SSH 密钥：

```bash
ls -al ~/.ssh
```

如果看到 `id_rsa` 和 `id_rsa.pub`（或者是 `id_ed25519` 和 `id_ed25519.pub`）等文件，说明你已有密钥。

如果没有，生成一个新的 SSH 密钥（以更现代的 Ed25519 算法为例）：

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

按回车接受默认保存位置，然后设置一个安全的密码（可选，但推荐）。

#### 2. 将 SSH 私钥添加到 ssh-agent

检查是否存在 SSH 密钥

打开终端，列出你的 `~/.ssh` 目录下的文件：

```bash
ls -al ~/.ssh
```

寻找一对名为 `id_rsa` & `id_rsa.pub` 或 `id_ed25519` & `id_ed25519.pub` 的文件。`.pub` 文件是公钥，另一个没有后缀的是私钥。

`ssh-agent` 是一个管理私钥的程序。你需要启动它并把你的密钥添加进去。

```bash
# 1. 确保 ssh-agent 在后台运行
eval "$(ssh-agent -s)"
# 这会输出类似：Agent pid 59566

# 2. 将你的 SSH 私钥添加到 ssh-agent
# 如果你使用的是默认的 id_rsa 文件
ssh-add ~/.ssh/id_rsa

# 如果你使用的是 Ed25519 算法生成的默认文件
ssh-add ~/.ssh/id_ed25519

# 如果你生成密钥时使用了其他名字，请指定那个名字
# ssh-add ~/.ssh/你的密钥文件名
```

#### 3. 将 SSH 公钥添加到 GitHub

复制公钥内容：

```bash
# 复制 id_ed25519.pub 或 id_rsa.pub 文件的内容
cat ~/.ssh/id_ed25519.pub
```

选中并复制输出的全部文本（以 `ssh-ed25519 ...` 或 `ssh-rsa ...` 开头）。

登录 `GitHub` -> `Settings` -> `SSH and GPG keys `-> `New SSH key`。

取个标题（如 `My Laptop`），将复制的内容粘贴到 Key（密钥）框中，点击 Add SSH key。

#### 3. 修改本地仓库的远程地址

你现在的远程地址是 HTTPS 格式（`https://github.com/...`），需要改为 SSH 格式（`git@github.com:...`）。

```bash
# 查看当前远程地址
git remote -v
# 输出应为 origin  https://github.com/Alipebt/Notes.git (fetch 和 push)

# 将其修改为 SSH 地址
git remote set-url origin git@github.com:Alipebt/Notes.git

# 再次确认是否修改成功
git remote -v
# 输出应变为 origin  git@github.com:Alipebt/Notes.git (fetch 和 push)
```

现在，再执行 `git push`，它可能会要求你输入一次 SSH 密钥的密码（如果你之前设置了的话），之后就不再需要任何用户名和密码了，非常方便。

#### 4. 再次测试

完成以上所有步骤后，再次运行连接测试命令：

```bash
ssh -T git@github.com
```

现在你应该能看到成功的消息了：

```
Hi Alipebt! You've successfully authenticated, but GitHub does not provide shell access.
```

最后，再次执行你的 `git push` 命令：

```bash
git push
```

这次应该就能成功完成了！

---

### 特殊情况：SSH 配置正确但 `git push` 仍然失败

当使用 `GIT_SSH_COMMAND="ssh -v" git push` 能成功，但单纯的 `git push` 失败时，说明：

- SSH 密钥和配置是正确的（因为加了 `-v` 就能工作）
- Git 默认没有使用你期望的 SSH 密钥（所以不加 `-v` 就失败）

根本原因是：你的 SSH 私钥文件名不是默认的（不是 `id_rsa` 或 `id_ed25519`），而 Git 默认只尝试这些标准名称的密钥。当你添加 `-v` 参数时，SSH 客户端的行为可能稍有不同，或者它成功找到了你的密钥，但默认情况下找不到。

以及22号端口有时会被防火墙限制，但大多数规则（或防火墙）都不会对 443 端口进行限制（基本上你能访问 Https 站点即代表 443 是放行的）

#### 解决方案

##### 方案一： SSH 配置文件

这是最干净、一劳永逸的方法。编辑或创建 SSH 客户端配置文件 `~/.ssh/config`：

```bash
# 打开或创建配置文件
vim ~/.ssh/config  # 或者使用 vim, code 等你喜欢的编辑器
```

在文件中添加以下内容，根据你的密钥文件名进行修改：

```shell
# 针对 GitHub 的特定配置
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/你的私钥文件名  # <--- 这是最关键的一行！
    IdentitiesOnly yes                  # <--- 这一行也很重要，强制只使用指定的密钥
```

以下是加入了更改端口的内容

```shell
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/你的私钥文件名
    IdentitiesOnly yes
```

当然，在配置之前可以先测试 443 的连通性（注意：支持 443 端口的域名为 `ssh.github.com` 非 `github.com`）

```shell
ssh -T -p 443 git@ssh.github.com
```

若如下输出，则表明连接成功

```shell
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

再次测试一下到 `GitHub` 的 SSH 连接是否通畅。

```bash
ssh -T git@github.com
```

保存文件后，再次尝试 `git push`，应该就能成功了。



##### 方案二：设置全局 Git 配置来指定 SSH 命令

你也可以通过 Git 配置来永久设置这个行为，但这不如方案一灵活：

```bash
git config --global core.sshCommand "ssh -i ~/.ssh/你的私钥文件名 -o IdentitiesOnly=yes"
```

(同样，将 `~/.ssh/你的私钥文件名` 替换为你的实际私钥路径)

##### 方案三：将你的密钥添加到 ssh-agent 并确保其已加载

虽然你之前可能已经做过，但我们可以确保万无一失：

```bash
# 1. 确保 ssh-agent 运行
eval "$(ssh-agent -s)"

# 2. 清空当前已加载的密钥列表（可选）
ssh-add -D

# 3. 添加你的特定密钥
ssh-add ~/.ssh/你的私钥文件名

# 4. 列出已加载的密钥，确认你的密钥在里面
ssh-add -l
```

之后再次尝试 `git push`。

