import Foundation

enum FormulaDisplayText {
    static func name(for formulaID: String) -> String {
        switch formulaID {
        case "F01": return "Profit & Loss Calculator"
        case "F02": return "Cost Averaging Calculator"
        case "F03": return "SIP Future Value Calculator"
        case "F04": return "Lumpsum Investment Calculator"
        case "F05": return "Return on Investment"
        case "F06": return "Compound Annual Growth Rate (CAGR)"
        case "F07": return "Price-to-Earnings Ratio (P/E)"
        case "F08": return "Earnings Per Share (EPS)"
        case "F09": return "Return on Equity (ROE)"
        case "F10": return "Dividend Yield"
        case "F11": return "Net Profit Margin"
        case "F12": return "Debt to Equity Ratio"
        case "F13": return "Total Return Calculator"
        case "F14": return "Holding Period Return"
        case "F15": return "Annualized Return"
        case "F16": return "Absolute Return"
        case "F17": return "Real Return"
        case "F18": return "Price to Book Ratio"
        case "F19": return "Price/Earnings to Growth Ratio (PEG)"
        case "F20": return "Enterprise Value to EBITDA (EV/EBITDA)"
        case "F21": return "Graham Intrinsic Value"
        case "F22": return "Discounted Cash Flow"
        case "F23": return "Earnings Yield"
        case "F24": return "Dividend Payout Ratio"
        case "F25": return "Sharpe Ratio (Risk-Adjusted Return)"
        case "F26": return "Portfolio Weighted Return"
        case "F27": return "Portfolio Beta"
        case "F28": return "Beta Calculator"
        case "F29": return "Jensen's Alpha"
        case "F30": return "Standard Deviation (Volatility)"
        case "F31": return "Value at Risk (VaR)"
        case "F32": return "Maximum Drawdown"
        case "F33": return "Relative Strength Index (RSI)"
        case "F34": return "Simple Moving Average"
        case "F35": return "Exponential Moving Average"
        case "F36": return "Moving Average Convergence Divergence (MACD)"
        case "F37": return "Bollinger Bands"
        case "F38": return "Stochastic Oscillator"
        case "F39": return "Pivot Points"
        case "F40": return "Return on Assets"
        case "F41": return "Current Ratio"
        case "F42": return "Operating Margin"
        case "F43": return "Gross Margin"
        case "F44": return "Interest Coverage Ratio"
        case "F45": return "Asset Turnover Ratio"
        case "F46": return "Yield to Maturity (YTM)"
        case "F47": return "Bond Price Calculator"
        case "F48": return "Bond Coupon Rate"
        case "F49": return "Options Breakeven Price"
        case "F50": return "Option Intrinsic Value"
        case "F51": return "Put-Call Parity (Theoretical Pricing Check)"
        case "F52": return "Black-Scholes Option Pricing Model"
        case "F53": return "Loan EMI Calculator"
        case "F54": return "Simple Interest Calculator"
        case "F55": return "GST Calculator"
        case "F56": return "Discount Calculator"
        case "F57": return "Target Savings Planner"
        case "F58": return "Loan Eligibility (EMI Capacity)"
        case "F59": return "Rental Yield Calculator"
        case "F60": return "Break-even Units Calculator"
        case "F61": return "Gross Profit Calculator"
        case "F62": return "Emergency Fund Target"
        case "F63": return "FIRE Corpus Planner"
        case "F64": return "Rule of 72"
        case "F65": return "Future Cost by Inflation"
        case "F66": return "Capital Gains Tax Estimator"
        case "F67": return "Post-Tax Income Calculator"
        case "F68": return "Required Pre-Tax Income"
        case "F69": return "Debt-to-Income Ratio (DTI)"
        case "F70": return "Monthly Savings Rate"
        case "F71": return "Net Worth Calculator"
        case "F72": return "Emergency Runway (Months)"
        case "F73": return "Required CAGR to Reach Target Amount"
        case "F74": return "Loan Prepayment Savings Calculator"
        case "F75": return "Monthly Withdrawal from Retirement Corpus"
        case "F76": return "Old vs New Tax Regime Comparison"
        default: return formulaID
        }
    }

    static func shortName(for formulaID: String) -> String {
        switch formulaID {
        case "F01": return "P&L"
        case "F02": return "Avg Down / Avg Up"
        case "F03": return "SIP Returns"
        case "F04": return "Lumpsum"
        case "F05": return "ROI"
        case "F06": return "CAGR"
        case "F07": return "P/E Ratio"
        case "F08": return "EPS"
        case "F09": return "ROE"
        case "F10": return "Div Yield"
        case "F11": return "NPM"
        case "F12": return "D/E Ratio"
        case "F13": return "Total Return"
        case "F14": return "HPR"
        case "F15": return "Ann. Return"
        case "F16": return "Abs. Return"
        case "F17": return "Real Return"
        case "F18": return "P/B Ratio"
        case "F19": return "PEG Ratio"
        case "F20": return "EV/EBITDA"
        case "F21": return "Graham Value"
        case "F22": return "DCF"
        case "F23": return "E/P Yield"
        case "F24": return "Payout Ratio"
        case "F25": return "Sharpe"
        case "F26": return "Portfolio Return"
        case "F27": return "Portfolio Beta"
        case "F28": return "Beta"
        case "F29": return "Alpha"
        case "F30": return "Std Dev"
        case "F31": return "VaR"
        case "F32": return "Max Drawdown"
        case "F33": return "RSI"
        case "F34": return "SMA"
        case "F35": return "EMA"
        case "F36": return "MACD"
        case "F37": return "BB"
        case "F38": return "Stochastic %K"
        case "F39": return "Pivot Points"
        case "F40": return "ROA"
        case "F41": return "Current Ratio"
        case "F42": return "Op. Margin"
        case "F43": return "Gross Margin"
        case "F44": return "ICR"
        case "F45": return "Asset Turnover"
        case "F46": return "YTM"
        case "F47": return "Bond Price"
        case "F48": return "Coupon Rate"
        case "F49": return "Options BEP"
        case "F50": return "Intrinsic Value"
        case "F51": return "PCP"
        case "F52": return "Black-Scholes"
        case "F53": return "EMI"
        case "F54": return "Simple Interest"
        case "F55": return "GST"
        case "F56": return "Discount %"
        case "F57": return "Goal SIP"
        case "F58": return "EMI Capacity"
        case "F59": return "Rent Yield"
        case "F60": return "Break-even Units"
        case "F61": return "Gross Profit"
        case "F62": return "Emergency Fund"
        case "F63": return "FIRE Corpus"
        case "F64": return "Rule 72"
        case "F65": return "Future Cost"
        case "F66": return "CG Tax"
        case "F67": return "Take-Home"
        case "F68": return "Req. Gross"
        case "F69": return "DTI Ratio"
        case "F70": return "Savings Rate"
        case "F71": return "Net Worth"
        case "F72": return "Runway"
        case "F73": return "Required CAGR"
        case "F74": return "Prepay Savings"
        case "F75": return "Monthly Withdrawal"
        case "F76": return "Tax Regime"
        default: return formulaID
        }
    }

    static func resolveStoredFormulaName(_ raw: String, formulaID: String?) -> String {
        if raw.hasPrefix("formula.f"), raw.hasSuffix(".name"), let id = parsedFormulaID(from: raw) {
            return name(for: id)
        }
        if let formulaID {
            return name(for: formulaID)
        }
        return raw
    }

    static func resolveStoredExpression(_ raw: String, formulaID: String?) -> String {
        if raw.hasPrefix("formula.f"), raw.hasSuffix(".expression"), let id = parsedFormulaID(from: raw) {
            return FormulaKnowledge.narrative(for: id, fallbackExpression: "").fullExpression
        }
        if let formulaID {
            return FormulaKnowledge.narrative(for: formulaID, fallbackExpression: raw).fullExpression
        }
        return raw
    }

    private static func parsedFormulaID(from key: String) -> String? {
        let parts = key.split(separator: ".")
        guard parts.count >= 3 else { return nil }
        let middle = String(parts[1]).uppercased()
        if middle.hasPrefix("F") {
            return middle
        }
        return nil
    }
}
