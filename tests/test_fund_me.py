from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest


def test_can_fund_and_withdraw():
    account = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee() + 100

    tx = fund_me.fundMe({"from": account, "value": entrance_fee})
    tx.wait(1)
    assert fund_me.fundMap(account.address) == entrance_fee
    tx2 = fund_me.withdrawMoney({"from": account})
    tx2.wait(1)
    assert fund_me.fundMap(account.address) == 0


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    account = get_account()
    fund_me = deploy_fund_me()
    bad_actor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdrawMoney({"from": bad_actor})


def main():
    test_can_fund_and_withdraw()
