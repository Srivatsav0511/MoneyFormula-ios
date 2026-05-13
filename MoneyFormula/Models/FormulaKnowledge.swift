import Foundation
import SwiftUI

struct FormulaVariableLine: Identifiable, Hashable {
    let id = UUID()
    let symbol: String
    let meaning: String
}

struct FormulaNarrative {
    let fullExpression: String
    let cardExpression: String
    let explanation: String

    init(fullExpression: String, explanation: String) {
        self.fullExpression = fullExpression
        self.cardExpression = FormulaKnowledge.compactExpression(from: fullExpression)
        self.explanation = explanation
    }
}

enum FormulaKnowledge {
    static func compactExpression(from expression: String) -> String {
        let firstChunk = expression
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? expression
        return firstChunk
            .replacingOccurrences(of: " x ", with: " * ")
            .replacingOccurrences(of: " / ", with: " / ")
    }

    static func narrative(for formulaID: String, fallbackExpression: String) -> FormulaNarrative {
        switch formulaID {
        case "F01":
            return .init(
                fullExpression: "Net P&L = (Sell Price - Buy Price) x Quantity - (Brokerage + STT + Exchange Charges + GST + Stamp Duty + SEBI Charges)",
                explanation: "Shows the money made or lost after all charges."
            )
        case "F02":
            return .init(
                fullExpression: "New Average = ((Old Shares x Old Avg) + (New Shares x Current Price)) / Total Shares",
                explanation: "Calculates your revised average after adding more shares at the current price."
            )
        case "F03":
            return .init(
                fullExpression: "Future Value = M x [((1 + r)^n - 1) / r] x (1 + r)",
                explanation: "Projects corpus growth with monthly investing and compounding."
            )
        case "F04":
            return .init(
                fullExpression: "Maturity = Principal x (1 + Rate/100)^Years",
                explanation: "Projects final value of one-time investment."
            )
        case "F05":
            return .init(
                fullExpression: "ROI(%) = ((Final - Initial) / Initial) x 100",
                explanation: "Measures percentage return versus initial investment."
            )
        case "F06":
            return .init(
                fullExpression: "CAGR(%) = ((Ending / Beginning)^(1/Years) - 1) x 100",
                explanation: "Shows smoothed annual growth rate across multiple years."
            )
        case "F07":
            return .init(
                fullExpression: "P/E Ratio = Market Price / Earnings Value",
                explanation: "Indicates how much is being paid for each unit of earnings."
            )
        case "F08":
            return .init(
                fullExpression: "EPS = (Net Income - Preferred Dividends) / Units Outstanding",
                explanation: "Shows earnings attributable to each outstanding unit."
            )
        case "F09":
            return .init(
                fullExpression: "ROE(%) = (Net Income / Shareholders Equity) x 100",
                explanation: "Measures profitability generated from shareholder capital."
            )
        case "F10":
            return .init(
                fullExpression: "Yield(%) = (Annual Cash Flow / Asset Price) x 100",
                explanation: "Shows annual cash yield relative to current asset price."
            )
        case "F11":
            return .init(
                fullExpression: "Net Profit Margin(%) = (Net Profit / Revenue) x 100",
                explanation: "Shows final profit retained from each unit of sales."
            )
        case "F12":
            return .init(
                fullExpression: "Debt to Equity = Total Liabilities / Shareholders Equity",
                explanation: "Measures leverage used relative to owner capital."
            )
        case "F13":
            return .init(
                fullExpression: "Total Return(%) = ((Sell - Buy + Dividends) / Buy) x 100",
                explanation: "Combines price change and dividends into one return metric."
            )
        case "F14":
            return .init(
                fullExpression: "HPR(%) = (Income + End Value - Initial Value) / Initial Value x 100",
                explanation: "Measures return for the exact holding window."
            )
        case "F15":
            return .init(
                fullExpression: "Annualized Return(%) = ((1 + TR/100)^(1/Years) - 1) x 100",
                explanation: "Converts total return to an annual equivalent rate."
            )
        case "F16":
            return .init(
                fullExpression: "Absolute Return(%) = ((Current - Invested) / Invested) x 100",
                explanation: "Simple percentage gain or loss from invested capital."
            )
        case "F17":
            return .init(
                fullExpression: "Real Return(%) = ((1 + Nominal/100) / (1 + Inflation/100) - 1) x 100",
                explanation: "Adjusts nominal return by inflation impact."
            )
        case "F18":
            return .init(
                fullExpression: "P/B Ratio = Market Price / Book Value Per Unit",
                explanation: "Compares market valuation to accounting net asset value."
            )
        case "F19":
            return .init(
                fullExpression: "PEG Ratio = P/E Ratio / EPS Growth Rate",
                explanation: "Relates valuation multiple to growth rate."
            )
        case "F20":
            return .init(
                fullExpression: "EV/EBITDA = (Market Cap + Debt - Cash) / EBITDA",
                explanation: "Enterprise-value multiple of operating cash earnings."
            )
        case "F21":
            return .init(
                fullExpression: "Intrinsic Value = EPS x (8.5 + 2g) x 4.4 / Y",
                explanation: "Graham-style fair value estimate using growth and bond yield."
            )
        case "F22":
            return .init(
                fullExpression: "DCF = Sum(CFt / (1 + r)^t)",
                explanation: "Discounts future cash flows into present value."
            )
        case "F23":
            return .init(
                fullExpression: "Earnings Yield(%) = (EPS / Market Price) x 100",
                explanation: "Inverse of P/E, used to compare to yields."
            )
        case "F24":
            return .init(
                fullExpression: "Dividend Payout Ratio(%) = (DPS / EPS) x 100",
                explanation: "Shows proportion of earnings paid as dividends."
            )
        case "F25":
            return .init(
                fullExpression: "Sharpe Ratio = (Portfolio Return - Risk Free Rate) / Std Deviation",
                explanation: "Measures risk-adjusted performance."
            )
        case "F26":
            return .init(
                fullExpression: "Portfolio Return = Sum(weight_i x return_i)",
                explanation: "Computes weighted return across holdings."
            )
        case "F27":
            return .init(
                fullExpression: "Portfolio Beta = Sum(weight_i x beta_i)",
                explanation: "Computes weighted sensitivity to market moves."
            )
        case "F28":
            return .init(
                fullExpression: "Beta = (Stock Return - Risk Free) / (Market Return - Risk Free)",
                explanation: "Measures volatility relative to market benchmark."
            )
        case "F29":
            return .init(
                fullExpression: "Alpha = Actual Return - [Rf + Beta x (Rm - Rf)]",
                explanation: "Shows outperformance or underperformance versus expected return."
            )
        case "F30":
            return .init(
                fullExpression: "Sigma = sqrt(Sum((x_i - mean)^2) / n)",
                explanation: "Measures return dispersion (volatility)."
            )
        case "F31":
            return .init(
                fullExpression: "VaR = Portfolio Value x Z-Score x Daily Volatility x sqrt(Days)",
                explanation: "Estimates maximum expected loss at selected confidence."
            )
        case "F32":
            return .init(
                fullExpression: "Max Drawdown(%) = (Peak - Trough) / Peak x 100",
                explanation: "Captures worst peak-to-trough decline."
            )
        case "F33":
            return .init(
                fullExpression: "RSI = 100 - [100 / (1 + AvgGain/AvgLoss)]",
                explanation: "Momentum oscillator between 0 and 100."
            )
        case "F34":
            return .init(
                fullExpression: "SMA = (P1 + P2 + ... + Pn) / n",
                explanation: "Arithmetic mean of selected prices."
            )
        case "F35":
            return .init(
                fullExpression: "EMA = Price x k + PrevEMA x (1 - k), where k = 2/(n+1)",
                explanation: "Weighted moving average that reacts faster to new prices."
            )
        case "F36":
            return .init(
                fullExpression: "MACD = EMA12 - EMA26, Signal = EMA9(MACD), Histogram = MACD - Signal",
                explanation: "Tracks trend momentum and turning points."
            )
        case "F37":
            return .init(
                fullExpression: "Upper = SMA + (Multiplier x Sigma), Lower = SMA - (Multiplier x Sigma)",
                explanation: "Volatility bands around moving average."
            )
        case "F38":
            return .init(
                fullExpression: "%K = (Close - Lowest Low) / (Highest High - Lowest Low) x 100",
                explanation: "Shows close position within recent range."
            )
        case "F39":
            return .init(
                fullExpression: "Pivot = (H + L + C)/3, R1 = 2Pivot - L, S1 = 2Pivot - H",
                explanation: "Derives support and resistance levels from prior period."
            )
        case "F40":
            return .init(
                fullExpression: "ROA(%) = (Net Income / Total Assets) x 100",
                explanation: "Measures profitability generated per asset base."
            )
        case "F41":
            return .init(
                fullExpression: "Current Ratio = Current Assets / Current Liabilities",
                explanation: "Liquidity metric for short-term obligations."
            )
        case "F42":
            return .init(
                fullExpression: "Operating Margin(%) = (Operating Income / Revenue) x 100",
                explanation: "Shows operating profitability before non-operating effects."
            )
        case "F43":
            return .init(
                fullExpression: "Gross Margin(%) = ((Revenue - COGS) / Revenue) x 100",
                explanation: "Shows gross profitability after direct costs."
            )
        case "F44":
            return .init(
                fullExpression: "Interest Coverage Ratio = EBIT / Interest Expense",
                explanation: "Indicates ability to service interest obligations."
            )
        case "F45":
            return .init(
                fullExpression: "Asset Turnover = Net Sales / ((Beginning Assets + Ending Assets)/2)",
                explanation: "Measures efficiency of asset utilization."
            )
        case "F46":
            return .init(
                fullExpression: "YTM(%) ~ [C + (F - P)/n] / [(F + P)/2] x 100",
                explanation: "Approximate annualized return if held to maturity."
            )
        case "F47":
            return .init(
                fullExpression: "Bond Price = Sum(Coupon/(1+r)^t) + Face/(1+r)^n",
                explanation: "Present value of coupons and principal."
            )
        case "F48":
            return .init(
                fullExpression: "Coupon Rate(%) = Annual Coupon Payment / Face Value x 100",
                explanation: "Annual coupon as a percentage of face value."
            )
        case "F49":
            return .init(
                fullExpression: "Call BEP = Strike + Premium, Put BEP = Strike - Premium",
                explanation: "Underlying price needed to recover premium at expiry."
            )
        case "F50":
            return .init(
                fullExpression: "Call Intrinsic = max(S - K, 0), Put Intrinsic = max(K - S, 0)",
                explanation: "Immediate exercisable value of an option."
            )
        case "F51":
            return .init(
                fullExpression: "Call + PV(Strike) = Put + Spot, PV(Strike) = K x e^(-rT)",
                explanation: "No-arbitrage relation linking call, put, spot price, and strike PV."
            )
        case "F52":
            return .init(
                fullExpression: "Call = S*N(d1) - K*e^(-rT)*N(d2), Put = K*e^(-rT)*N(-d2) - S*N(-d1)",
                explanation: "Black-Scholes theoretical option pricing for European options."
            )
        case "F53":
            return .init(
                fullExpression: "EMI = P x r x (1+r)^n / ((1+r)^n - 1)",
                explanation: "Computes monthly installment for a loan tenure."
            )
        case "F54":
            return .init(
                fullExpression: "Simple Interest = (Principal x Rate x Time) / 100; Amount = Principal + Interest",
                explanation: "Quick interest estimate without compounding."
            )
        case "F55":
            return .init(
                fullExpression: "GST Value = Amount x GST% / 100; Final Bill = Amount + GST",
                explanation: "Breaks tax component and final payable amount."
            )
        case "F56":
            return .init(
                fullExpression: "Discount(%) = ((Marked Price - Selling Price) / Marked Price) x 100",
                explanation: "Shows discount percentage and cash saved."
            )
        case "F57":
            return .init(
                fullExpression: "Monthly Saving = Target x r / (((1+r)^n - 1) x (1+r))",
                explanation: "Estimates required monthly savings to reach a future goal."
            )
        case "F58":
            return .init(
                fullExpression: "Affordable EMI = (Monthly Income x FOIR%) - Existing Obligations",
                explanation: "Estimates additional EMI capacity based on income and obligations."
            )
        case "F59":
            return .init(
                fullExpression: "Rental Yield(%) = (Monthly Rent x 12 / Property Price) x 100",
                explanation: "Evaluates annual rent return on property value."
            )
        case "F60":
            return .init(
                fullExpression: "Break-even Units = Fixed Cost / (Selling Price per Unit - Variable Cost per Unit)",
                explanation: "Units needed so contribution covers fixed costs."
            )
        case "F61":
            return .init(
                fullExpression: "Gross Profit = Revenue - COGS",
                explanation: "Amount left after direct costs of goods/services."
            )
        case "F62":
            return .init(
                fullExpression: "Emergency Fund Target = Monthly Expense x Coverage Months",
                explanation: "Recommended reserve for financial safety."
            )
        case "F63":
            return .init(
                fullExpression: "FIRE Corpus = Annual Expense / Withdrawal Rate",
                explanation: "Corpus estimate for long-term financial independence."
            )
        case "F64":
            return .init(
                fullExpression: "Years to Double ≈ 72 / Annual Return(%)",
                explanation: "Quick approximation for doubling time."
            )
        case "F65":
            return .init(
                fullExpression: "Future Cost = Current Cost x (1 + Inflation)^Years",
                explanation: "Projects future cost considering inflation."
            )
        case "F66":
            return .init(
                fullExpression: "Capital Gains Tax = Gain Amount x Tax Rate / 100",
                explanation: "Estimates tax payable on realized gains."
            )
        case "F67":
            return .init(
                fullExpression: "Post-Tax Income = Gross Income x (1 - Effective Tax Rate/100)",
                explanation: "Calculates take-home amount after estimated taxes."
            )
        case "F68":
            return .init(
                fullExpression: "Required Gross = Target Net Income / (1 - Effective Tax Rate/100)",
                explanation: "Finds pre-tax income needed to meet a net goal."
            )
        case "F69":
            return .init(
                fullExpression: "Debt-to-Income(%) = Monthly Debt / Monthly Income x 100",
                explanation: "Shows debt load as a percentage of monthly income."
            )
        case "F70":
            return .init(
                fullExpression: "Savings Rate(%) = Monthly Savings / Monthly Income x 100",
                explanation: "Measures what share of income you save each month."
            )
        case "F71":
            return .init(
                fullExpression: "Net Worth = Total Assets - Total Liabilities",
                explanation: "Core personal balance sheet metric."
            )
        case "F72":
            return .init(
                fullExpression: "Emergency Runway (months) = Cash Reserve / Monthly Expense",
                explanation: "How many months your cash can fund current spending."
            )
        case "F73":
            return .init(
                fullExpression: "Required CAGR(%) = ((Target Amount / Current Amount)^(1/Years) - 1) x 100",
                explanation: "Annualized return required to reach your target corpus in time."
            )
        case "F74":
            return .init(
                fullExpression: "Prepayment Impact compares normal EMI plan vs EMI + Extra EMI each month",
                explanation: "Shows interest saved and tenure reduced by monthly prepayment."
            )
        case "F75":
            return .init(
                fullExpression: "Monthly Withdrawal = Corpus x r / (1 - (1 + r)^(-n)), where r = monthly return",
                explanation: "Sustainable monthly withdrawal from corpus for selected years."
            )
        case "F76":
            return .init(
                fullExpression: "Compare Old Regime tax vs New Regime tax after eligible deductions and cess",
                explanation: "Shows side-by-side tax impact and take-home for both tax regimes."
            )
        default:
            return .init(fullExpression: fallbackExpression, explanation: "Calculates the selected financial metric from provided inputs.")
        }
    }

    static func variableLines(for formula: FormulaDefinition) -> [FormulaVariableLine] {
        formula.inputs.map { input in
            FormulaVariableLine(symbol: symbol(for: input.key), meaning: meaning(for: input.key))
        }
    }

    static func formulaSteps(for formula: FormulaDefinition) -> [FormulaStep] {
        let narrative = narrative(for: formula.id, fallbackExpression: formula.formulaExpressionKey)
        let variableSymbols = variableLines(for: formula).map(\.symbol)
        let summary = variableSymbols.isEmpty ? "your inputs" : variableSymbols.joined(separator: ", ")

        return [
            FormulaStep(
                title: "Base Formula",
                expression: narrative.fullExpression,
                result: "Start with the standard equation.",
                explanation: "This is the core relationship used for this calculator."
            ),
            FormulaStep(
                title: "Substitute Values",
                expression: narrative.fullExpression,
                result: "Replace \(summary) with your entered values.",
                explanation: "Plug in your numbers so the equation becomes specific to your case."
            ),
            FormulaStep(
                title: "Evaluate",
                expression: "Apply arithmetic operations in order.",
                result: "Compute the final output shown in the result card.",
                explanation: "The app evaluates the expression and formats the answer based on unit and decimal settings."
            )
        ]
    }

    private static func symbol(for key: String) -> String {
        switch key {
        case "buyPrice": return "Buy"
        case "sellPrice": return "Sell"
        case "quantity": return "Qty"
        case "brokerage": return "Brokerage %"
        case "stt": return "STT %"
        case "exchangeCharges": return "Exchange %"
        case "stampDuty": return "Stamp Duty %"
        case "gstOnBrokerageAmount": return "GST"
        case "sebiChargesAmount": return "SEBI"
        case "oldShares": return "Q1"
        case "oldAvg": return "P1"
        case "newShares": return "Q2"
        case "newPrice": return "P2"
        case "targetAvg": return "Target"
        case "monthly": return "M"
        case "annualReturn": return "r"
        case "years": return "n"
        case "actualReturn": return "Rp"
        case "assets": return "Assets"
        case "avgGain": return "Avg Gain"
        case "avgLoss": return "Avg Loss"
        case "beginAssets": return "Begin Assets"
        case "callPrice": return "Call"
        case "cash": return "Cash"
        case "cashFlow": return "CF"
        case "close": return "Close"
        case "cogs": return "COGS"
        case "confidence": return "CL"
        case "coupon": return "C"
        case "couponPayment": return "Coupon"
        case "couponRate": return "Coupon %"
        case "current": return "Current"
        case "currentAssets": return "Current Assets"
        case "currentLiabilities": return "Current Liabilities"
        case "currentPrice": return "Current Price"
        case "dailyVolatility": return "Daily sigma"
        case "days": return "t"
        case "debt": return "Debt"
        case "discount": return "r"
        case "dividend": return "DPS"
        case "dividends": return "Div"
        case "ebit": return "EBIT"
        case "ebitda": return "EBITDA"
        case "ema12": return "EMA12"
        case "ema26": return "EMA26"
        case "endAssets": return "End Assets"
        case "endValue": return "End Value"
        case "growth": return "g"
        case "high": return "High"
        case "income": return "Income"
        case "inflation": return "Inflation"
        case "interestExpense": return "Interest"
        case "isCall": return "Type"
        case "marketCap": return "MCap"
        case "marketRate": return "Market Rate"
        case "netIncome": return "Net Income"
        case "netProfit": return "Net Profit"
        case "nominal": return "Nominal"
        case "operatingIncome": return "Op Income"
        case "pe": return "P/E"
        case "period": return "Period"
        case "portfolioValue": return "Portfolio"
        case "preferredDividends": return "Pref Div"
        case "premium": return "Premium"
        case "previousEMA": return "Prev EMA"
        case "putPrice": return "Put"
        case "return": return "Return"
        case "returns": return "Returns"
        case "sales": return "Sales"
        case "sharesOutstanding": return "Shares"
        case "signalPrev": return "Prev Signal"
        case "sma": return "SMA"
        case "stockName": return "Stock"
        case "stockReturn": return "Rs"
        case "totalReturn": return "TR"
        case "weight": return "Weight"
        case "yield": return "Y"
        case "initial", "initialValue", "invested", "investment", "beginning": return "Initial"
        case "final", "ending": return "Final"
        case "eps": return "EPS"
        case "marketPrice": return "Price"
        case "portfolioReturn": return "Rp"
        case "riskFree": return "Rf"
        case "stdDev": return "sigma"
        case "beta": return "beta"
        case "marketReturn": return "Rm"
        case "face": return "F"
        case "price": return "P"
        case "strike": return "K"
        case "stock": return "S"
        case "time": return "T"
        case "volatility": return "sigma"
        case "loanAmount": return "Loan"
        case "annualRate": return "Rate"
        case "principal": return "P"
        case "rate": return "R"
        case "amount": return "Amount"
        case "gstRate": return "GST%"
        case "markedPrice": return "MRP"
        case "sellingPrice": return "SP"
        case "target": return "Target"
        case "monthlyIncome": return "Income"
        case "foir": return "FOIR"
        case "existingObligations": return "Existing EMI"
        case "monthlyRent": return "Rent"
        case "propertyPrice": return "Property"
        case "fixedCost": return "Fixed Cost"
        case "sellingPricePerUnit": return "SP/Unit"
        case "variableCostPerUnit": return "VC/Unit"
        case "monthlyExpense": return "Expense"
        case "months": return "Months"
        case "annualExpense": return "Annual Exp"
        case "withdrawalRate": return "WR"
        case "currentCost": return "Current"
        case "gainAmount": return "Gain"
        case "taxRate": return "Tax %"
        case "grossIncome": return "Gross"
        case "effectiveTaxRate": return "Eff. Tax %"
        case "targetNetIncome": return "Net Target"
        case "monthlyDebt": return "Debt"
        case "monthlySavings": return "Savings"
        case "totalAssets": return "Assets"
        case "totalLiabilities": return "Liabilities"
        case "cashReserve": return "Cash"
        case "currentAmount": return "Current"
        case "targetAmount": return "Target"
        case "extraEMI": return "Extra EMI"
        case "corpus": return "Corpus"
        case "grossSalary": return "Gross"
        case "standardDeduction": return "Std Deduction"
        case "hraExemption": return "HRA"
        case "section80C": return "80C"
        case "section80D": return "80D"
        case "nps80ccd1b": return "80CCD(1B)"
        case "homeLoan24b": return "24(b)"
        case "otherDeductions": return "Other Ded."
        default: return key
        }
    }

    private static func meaning(for key: String) -> String {
        switch key {
        case "actualReturn": return "Actual portfolio return percentage."
        case "annualReturn": return "Expected annual return percentage."
        case "assets": return "Total assets of the company."
        case "avgGain": return "Average gain over the chosen period."
        case "avgLoss": return "Average loss over the chosen period."
        case "beginAssets": return "Asset value at the beginning."
        case "beginning": return "Beginning investment value."
        case "buyPrice": return "Price at which shares were bought."
        case "callPrice": return "Current call option price."
        case "cash": return "Cash and cash equivalents."
        case "cashFlow": return "Annual cash flow amount."
        case "close": return "Closing price."
        case "cogs": return "Cost of goods sold."
        case "confidence": return "Confidence level for risk estimate."
        case "coupon": return "Annual coupon payment."
        case "couponPayment": return "Annual coupon amount paid."
        case "couponRate": return "Annual coupon rate percentage."
        case "current": return "Current value."
        case "currentAssets": return "Assets expected within one year."
        case "currentLiabilities": return "Liabilities due within one year."
        case "currentPrice": return "Current market price."
        case "dailyVolatility": return "Expected daily volatility percentage."
        case "days": return "Time horizon in days."
        case "debt": return "Total debt outstanding."
        case "discount": return "Discount rate used for present value."
        case "dividend": return "Annual dividend or cash payout."
        case "dividends": return "Dividends received."
        case "ebit": return "Earnings before interest and tax."
        case "ebitda": return "Earnings before interest, tax, depreciation, and amortization."
        case "ema12": return "12-period exponential moving average."
        case "ema26": return "26-period exponential moving average."
        case "endAssets": return "Asset value at the end."
        case "ending": return "Ending investment value."
        case "endValue": return "Final value at the end of period."
        case "eps": return "Earnings per unit."
        case "equity": return "Shareholders' equity."
        case "face": return "Face (par) value."
        case "final": return "Final value."
        case "growth": return "Expected growth rate percentage."
        case "high": return "Highest price in period."
        case "income": return "Income received during holding period."
        case "inflation": return "Inflation rate percentage."
        case "initial": return "Initial amount invested."
        case "initialValue": return "Initial value at start of period."
        case "interestExpense": return "Interest expense amount."
        case "invested": return "Amount originally invested."
        case "investment": return "One-time invested amount."
        case "isCall": return "Option type (Call or Put)."
        case "liabilities": return "Total liabilities."
        case "low": return "Lowest price in period."
        case "marketCap": return "Market capitalization."
        case "marketPrice": return "Current market price of the asset."
        case "marketRate": return "Current market interest rate."
        case "marketReturn": return "Benchmark market return percentage."
        case "monthly": return "Monthly SIP contribution."
        case "multiplier": return "Band multiplier for standard deviation."
        case "netIncome": return "Net profit after all expenses."
        case "netProfit": return "Net profit amount."
        case "newPrice": return "Price of additional units."
        case "newShares": return "Additional units to buy."
        case "nominal": return "Nominal return before inflation."
        case "oldAvg": return "Current average acquisition price."
        case "oldShares": return "Current number of held units."
        case "operatingIncome": return "Operating profit before non-operating items."
        case "pe": return "Price-to-earnings ratio."
        case "period": return "Number of periods."
        case "portfolioReturn": return "Portfolio return percentage."
        case "portfolioValue": return "Current total portfolio value."
        case "preferredDividends": return "Dividends paid to preferred shareholders."
        case "premium": return "Option premium paid."
        case "previousEMA": return "Previous EMA value."
        case "price": return "Current market price."
        case "putPrice": return "Current put option price."
        case "return": return "Return percentage."
        case "returns": return "Series of periodic returns."
        case "revenue": return "Total revenue."
        case "riskFree": return "Risk-free benchmark rate."
        case "sales": return "Net sales amount."
        case "sellPrice": return "Price at which units were sold."
        case "sharesOutstanding": return "Total units outstanding."
        case "signalPrev": return "Previous signal line EMA value."
        case "sma": return "Simple moving average."
        case "stdDev": return "Standard deviation of returns."
        case "stock": return "Current underlying stock price."
        case "stockName": return "Stock identifier."
        case "stockReturn": return "Stock return percentage."
        case "strike": return "Option strike price."
        case "stt": return "Securities Transaction Tax percentage."
        case "exchangeCharges": return "NSE/BSE transaction charges percentage on turnover."
        case "stampDuty": return "Stamp duty percentage applied on buy turnover."
        case "gstOnBrokerageAmount": return "GST amount auto-calculated as 18% of brokerage."
        case "sebiChargesAmount": return "SEBI turnover charges amount."
        case "targetAvg": return "Desired post-purchase average price."
        case "time": return "Time to expiry in years."
        case "totalReturn": return "Total return percentage."
        case "volatility": return "Annualized implied volatility."
        case "weight": return "Portfolio weight percentage."
        case "years": return "Time horizon in years."
        case "yield": return "Reference bond yield percentage."
        case "quantity": return "Number of units."
        case "brokerage": return "Broker charge percentage."
        case "loanAmount": return "Principal loan amount."
        case "annualRate": return "Annual interest rate."
        case "principal": return "Principal amount."
        case "rate": return "Simple interest annual rate."
        case "amount": return "Pre-tax amount."
        case "gstRate": return "GST percentage rate."
        case "markedPrice": return "Original marked price."
        case "sellingPrice": return "Final selling price."
        case "target": return "Future target amount."
        case "monthlyIncome": return "Monthly take-home income."
        case "foir": return "Fixed obligation to income ratio limit."
        case "existingObligations": return "Current total monthly EMI obligations."
        case "monthlyRent": return "Expected monthly rent."
        case "propertyPrice": return "Current property market value."
        case "fixedCost": return "Fixed operating cost."
        case "sellingPricePerUnit": return "Selling price per unit."
        case "variableCostPerUnit": return "Variable cost per unit."
        case "monthlyExpense": return "Average monthly living expense."
        case "months": return "Number of months to cover."
        case "annualExpense": return "Total yearly expense."
        case "withdrawalRate": return "Safe annual withdrawal rate percentage."
        case "currentCost": return "Present-day cost."
        case "gainAmount": return "Realized taxable gain."
        case "taxRate": return "Applicable capital gains tax percentage."
        case "grossIncome": return "Income before taxes."
        case "effectiveTaxRate": return "Estimated blended tax rate percentage."
        case "targetNetIncome": return "Desired post-tax income."
        case "monthlyDebt": return "Total monthly debt obligations."
        case "monthlySavings": return "Amount saved per month."
        case "totalAssets": return "Total value of all assets."
        case "totalLiabilities": return "Total outstanding liabilities."
        case "cashReserve": return "Liquid cash and emergency reserves."
        case "currentAmount": return "Current value you have today."
        case "targetAmount": return "Future target value you want to reach."
        case "extraEMI": return "Additional EMI paid every month as prepayment."
        case "corpus": return "Total retirement corpus available today."
        case "grossSalary": return "Your annual gross salary before taxes."
        case "standardDeduction": return "Standard deduction amount under the old regime."
        case "hraExemption": return "HRA exemption amount eligible under old regime."
        case "section80C": return "Eligible Section 80C investments."
        case "section80D": return "Health insurance deduction under Section 80D."
        case "nps80ccd1b": return "Additional NPS deduction under 80CCD(1B)."
        case "homeLoan24b": return "Home loan interest deduction under Section 24(b)."
        case "otherDeductions": return "Any additional deductions you want to include."
        default:
            return key.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
        }
    }
}
