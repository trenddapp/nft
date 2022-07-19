from brownie import TDReactiveNFT
from scripts.useful import get_account


def main():
    TDReactiveNFT.deploy({"from": get_account()}, publish_source=True)
