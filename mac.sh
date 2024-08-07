#!/bin/bash

# 检查是否以 root 用户运行
if [ "$(id -u)" -ne "0" ]; then
    echo "请使用 root 权限运行此脚本"
    exit 1
fi

# 函数：安装 Node 和相关工具
function install_node() {
    echo "更新系统软件包..."
    brew update

    echo "安装必要的工具和依赖..."
    brew install curl git openssl pkg-config screen jq

    echo "正在安装 Rust 和 Cargo..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env

    echo "正在安装 Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"

    # 检查 solana-keygen 是否在 PATH 中
    if ! command -v solana-keygen &> /dev/null; then
        echo "将 Solana CLI 添加到 PATH"
        export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    echo "正在创建 Solana 密钥对..."
    solana-keygen new --derivation-path m/44'/501'/0'/0' --force | tee solana-keygen-output.txt

    echo "请确保你已经备份了上面显示的助记词和私钥信息。"
    echo "请向pubkey充值sol资产，用于挖矿gas费用。"
    read -p "备份完成后，请输入 'yes' 继续：" user_confirmation

    if [[ "$user_confirmation" == "yes" ]]; then
        echo "确认备份。继续执行脚本..."
    else
        echo "脚本终止。请确保备份你的信息后再运行脚本。"
        exit 1
    fi

    echo "正在安装 Ore CLI..."
    cargo install ore-cli

    # 检查并将 Solana 的路径添加到 .zshrc
    grep -qxF 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.zshrc
    grep -qxF 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc

    read -p "请输入自定义的 RPC 地址，建议使用免费的 Quicknode 或者 Alchemy SOL RPC (默认设置使用 https://api.mainnet-beta.solana.com): " custom_rpc
    RPC_URL=${custom_rpc:-https://api.mainnet-beta.solana.com}

    read -p "请输入挖矿时要使用的线程数 (默认设置 1): " custom_threads
    THREADS=${custom_threads:-1}

    read -p "请输入交易的优先费用 (默认设置 1): " custom_priority_fee
    PRIORITY_FEE=${custom_priority_fee:-1}

    session_name="ore"
    echo "开始挖矿，会话名称为 $session_name ..."
    start="while true; do ore --rpc $RPC_URL --keypair ~/.config/solana/id.json --priority-fee $PRIORITY_FEE mine --threads $THREADS; echo '进程异常退出，等待重启' >&2; sleep 1; done"
    screen -dmS "$session_name" bash -c "$start"

    echo "挖矿进程已在名为 $session_name 的 screen 会话中后台启动。"
    echo "使用 'screen -r $session_name' 命令重新连接到此会话。"
}

# 函数：导出钱包
function export_wallet() {
    echo "更新系统软件包..."
    brew update

    echo "安装必要的工具和依赖..."
    brew install curl git openssl pkg-config screen jq

    echo "正在恢复 Solana 钱包..."
    echo "下方请粘贴/输入你的助记词，用空格分隔，盲文不会显示的"
    solana-keygen recover 'prompt:?key=0/0' --force

    echo "钱包已恢复。"
    echo "请确保你的钱包地址已经充足的 SOL 用于交易费用。"

    # 检查并将 Solana 的路径添加到 .zshrc
    grep -qxF 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.zshrc
    grep -qxF 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc

    read -p "请输入自定义的 RPC 地址，建议使用免费的 Quicknode 或者 Alchemy SOL RPC (默认设置使用 https://api.mainnet-beta.solana.com): " custom_rpc
    RPC_URL=${custom_rpc:-https://api.mainnet-beta.solana.com}

    read -p "请输入挖矿时要使用的线程数 (默认设置 1): " custom_threads
    THREADS=${custom_threads:-1}

    read -p "请输入交易的优先费用 (默认设置 1): " custom_priority_fee
    PRIORITY_FEE=${custom_priority_fee:-1}

    session_name="ore"
    echo "开始挖矿，会话名称为 $session_name ..."
    start="while true; do ore --rpc $RPC_URL --keypair ~/.config/solana/id.json --priority-fee $PRIORITY_FEE mine --threads $THREADS; echo '进程异常退出，等待重启' >&2; sleep 1; done"
    screen -dmS "$session_name" bash -c "$start"

    echo "挖矿进程已在名为 $session_name 的 screen 会话中后台启动。"
    echo "使用 'screen -r $session_name' 命令重新连接到此会话。"
}

# 函数：启动服务
function start() {
    echo "启动服务..."
    # 在这里添加启动服务的具体命令
}

# 函数：检查日志
function check_logs() {
    echo "检查日志..."
    # 在这里添加检查日志的具体命令
}

# 函数：更新 Scout 容器
function update_scout() {
    echo "更新 Scout 容器..."
    # 停止并移除现有容器
    docker stop scout
    docker rm scout

    # 拉取最新的 Docker 镜像
    docker pull your-scout-image:latest

    # 运行更新后的容器
    docker run -d --name scout your-scout-image:latest
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "主菜单"
        echo "1) 安装 Node 和相关工具"
        echo "2) 导出钱包"
        echo "3) 启动服务"
        echo "4) 检查日志"
        echo "5) 更新 Scout 容器"
        echo "6) 退出"

        read -p "请输入选项: " choice
        case $choice in
            1) install_node ;;
            2) export_wallet ;;
            3) start ;;
            4) check_logs ;;
            5) update_scout ;;
            6) exit ;;
            *) echo "无效的选项" ;;
        esac
        read -p "按任意键返回主菜单..."
    done
}

main_menu
