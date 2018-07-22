package ca.td.td4m3.dashboard.creditCard.presenter

import ca.td.td4m3.dashboard.creditCard.contract.CreditCardView
import com.android.volley.VolleyError
import com.ngam.rvabstractions.AbstractPresenter
import com.td.virtualbank.VirtualBankAccount
import com.td.virtualbank.VirtualBankGetCustomerAccountsRequest
import com.td.virtualbank.VirtualBankGetTransactionsRequest
import com.td.virtualbank.VirtualBankTransaction
import java.util.*

class CreditCardPresenter(val view: CreditCardView): AbstractPresenter() {
    enum class CreditCardState {
        FULL_ERROR,
        PARTIAL_ERROR,
        SHIMMER,
        LOADED
    }

    private var accountTransactionsMap: HashMap<VirtualBankAccount, ArrayList<VirtualBankTransaction>> = HashMap()
    private var vendorsMap: HashMap<String, Int> = HashMap()
    private var currentState: CreditCardState = CreditCardState.SHIMMER
    private var numCCAccounts: Int = 0

    override fun onViewReady() {
        // Cannot request just CC because requesting transactions requires different object
        view.requestAccounts()
    }

    fun getAccountHandler(): VirtualBankGetCustomerAccountsRequest {
        return object: VirtualBankGetCustomerAccountsRequest() {
            override fun onSuccess(var1: ArrayList<VirtualBankAccount>) {
                val accountList: ArrayList<VirtualBankAccount> = var1
                val ccAccountList: ArrayList<VirtualBankAccount> = getCreditCardAccounts(accountList)
                numCCAccounts = ccAccountList.size
                if (ccAccountList.isEmpty()) {
                    // No CC accounts or transactions. Can only show product data
                    currentState = CreditCardState.PARTIAL_ERROR
                    return
                }

                // Make request for transactions for each CC account
                for (account in ccAccountList) {
                    view.requestTransactionsForAccount(account)
                }
            }

            override fun onError(p0: VolleyError?) {
                currentState = CreditCardState.FULL_ERROR
                view.reloadView()
            }
        }
    }

    private fun getCreditCardAccounts(accountList: ArrayList<VirtualBankAccount>): ArrayList<VirtualBankAccount> {
        val ccAccounts: ArrayList<VirtualBankAccount> = ArrayList()
        for (account in accountList) {
            // Apparently all CCs are just "VISA"
            if (account.type == "VISA") {
                ccAccounts.add(account)
            }
        }
        return ccAccounts
    }

    fun getTransactionsHandler(account: VirtualBankAccount): VirtualBankGetTransactionsRequest {
        currentState = CreditCardState.LOADED
        return object: VirtualBankGetTransactionsRequest() {
            override fun onSuccess(var1: ArrayList<VirtualBankTransaction>) {
                accountTransactionsMap[account] = var1
                if (accountTransactionsMap.keys.size == numCCAccounts) {
                    currentState = CreditCardState.LOADED
                    view.reloadView()
                }
            }

            override fun onError(p0: VolleyError?) {
                // Assume user has no transactions or cannot get
                currentState = CreditCardState.FULL_ERROR
                view.reloadView()
            }
        }
    }

    fun getCardState(): CreditCardState {
        return currentState
    }

    fun calculateSpending(): Double {
        var totalSpending = 0.0
        for (account in accountTransactionsMap.keys) {
            for (transaction in accountTransactionsMap[account].orEmpty()) {
                totalSpending += + transaction.currencyAmount
                vendorsMap[transaction.description] = (vendorsMap[transaction.description] ?: 0) + 1
            }
        }
        return totalSpending
    }

    fun getMostPopularVendor(): String? {
        if (vendorsMap.keys.isEmpty()) {
            return null
        }
        vendorsMap.toSortedMap()
        return ""
    }
}