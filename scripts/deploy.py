from brownie import TrendDapp
from scripts.useful import get_account


def main():
    TrendDapp.deploy({"from": get_account()}, publish_source=True)
