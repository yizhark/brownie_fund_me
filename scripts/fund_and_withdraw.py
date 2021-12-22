from brownie import fund
from scripts.helpful_scripts import get_account


def fundFunc():
    fund_me = fund[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    # print(f"price: {fund_me.getPrice()}")
    print(f"The current entry fee is {entrance_fee}")
    print("Funding")
    fund_me.fundMe({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = fund[-1]
    account = get_account()
    fund_me.withdrawMoney({"from": account})


def main():
    fundFunc()
    withdraw()
