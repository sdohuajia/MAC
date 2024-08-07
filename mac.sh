#!/bin/bash

# 更新 Homebrew
echo "更新 Homebrew..."
brew update

# 安装 build-essential 依赖
echo "安装 build-essential 依赖..."
brew install gcc

# 安装 Rust 环境
echo "安装 Rust 环境..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 配置环境变量
echo "配置环境变量..."
source $HOME/.cargo/env

# 验证 Rust 安装
echo "验证 Rust 安装..."
rustc --version
cargo --version

# 安装 Solana 开发环境
echo "安装 Solana 开发环境..."
sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"

# 配置 Solana 环境变量
echo "配置 Solana 环境变量..."
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# 验证 Solana 安装
echo "验证 Solana 安装..."
solana --version

# 安装 ore-cli
echo "安装 ore-cli..."
cargo install ore-cli

# 验证 ore-cli 安装
echo "验证 ore-cli 安装..."
ore-cli --version

# 创建 Solana 钱包
echo "创建 Solana 钱包..."
solana-keygen new --outfile ~/.config/solana/my-solana-wallet.json

# 提示用户如何找到钱包地址和替换私钥
echo ""
echo "Solana 钱包已创建！"
echo "钱包文件位置: ~/.config/solana/my-solana-wallet.json"
echo "请根据需要替换私钥或者使用新钱包。"
echo "要查看钱包地址，可以使用以下命令:"
echo "  solana-keygen pubkey ~/.config/solana/my-solana-wallet.json"
echo ""
echo "如果你想替换现有的钱包私钥，可以将新的私钥文件替换到该位置，或者使用新的钱包文件。"

# 提示用户输入 RPC 服务器地址
read -p "请输入 Solana RPC 服务器地址 (例如: https://api.mainnet-beta.solana.com): " rpc_url

# 开始挖矿
echo "开始挖矿..."
ore-cli --rpc "$rpc_url" --keypair ~/.config/solana/my-solana-wallet.json --priority-fee 1 mine --threads 4

echo "Rust、Solana 开发环境、ore-cli 和 Solana 钱包创建完成！挖矿已开始。"
