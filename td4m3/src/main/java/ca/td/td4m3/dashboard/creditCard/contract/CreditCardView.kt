package ca.td.td4m3.dashboard.creditCard.contract

import com.td.virtualbank.VirtualBankAccount

interface CreditCardView {
    fun reloadView()

    fun requestAccounts()

    fun requestTransactionsForAccount(account: VirtualBankAccount)
}