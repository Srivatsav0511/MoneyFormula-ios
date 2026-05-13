import Foundation

enum AllFormulas {
    private static func input(
        _ key: String,
        _ labelKey: String,
        _ unitKey: String,
        _ placeholderKey: String,
        optional: Bool = false,
        defaultValue: String? = nil,
        dynamic: Bool = false
    ) -> InputDefinition {
        InputDefinition(
            key: key,
            labelKey: labelKey,
            unitKey: unitKey,
            placeholderKey: placeholderKey,
            isOptional: optional,
            defaultValue: defaultValue,
            isDynamic: dynamic
        )
    }

    static let all: [FormulaDefinition] = [
        FormulaDefinition(
            id: "F01",
            nameKey: "formula.f01.name",
            shortNameKey: "formula.f01.short",
            descriptionKey: "formula.f01.description",
            formulaExpressionKey: "formula.f01.expression",
            category: .portfolio,
            sfSymbol: "chart.bar.xaxis",
            inputs: [
                input("buyPrice", "input.buy_price", "unit.currency", "placeholder.buy_price"),
                input("sellPrice", "input.sell_price", "unit.currency", "placeholder.sell_price"),
                input("quantity", "input.quantity", "unit.shares", "placeholder.quantity"),
                input("brokerage", "input.brokerage", "unit.percent", "placeholder.brokerage", defaultValue: "0.1"),
                input("stt", "input.stt", "unit.percent", "placeholder.stt", defaultValue: "0.1"),
                input("exchangeCharges", "input.exchange_transaction_charges", "unit.percent", "placeholder.exchange_transaction_charges", defaultValue: "0.00345"),
                input("stampDuty", "input.stamp_duty", "unit.percent", "placeholder.stamp_duty", defaultValue: "0.015")
            ],
            isPriority: true,
            displayOrder: 1
        ),
        FormulaDefinition(
            id: "F02",
            nameKey: "formula.f02.name",
            shortNameKey: "formula.f02.short",
            descriptionKey: "formula.f02.description",
            formulaExpressionKey: "formula.f02.expression",
            category: .portfolio,
            sfSymbol: "equal.circle",
            inputs: [
                input("oldShares", "input.old_shares", "unit.shares", "placeholder.old_shares"),
                input("oldAvg", "input.old_average_price", "unit.currency", "placeholder.old_average_price"),
                input("newShares", "input.new_shares", "unit.shares", "placeholder.new_shares"),
                input("newPrice", "input.new_buy_price", "unit.currency", "placeholder.new_buy_price")
            ],
            isPriority: true,
            displayOrder: 2
        ),
        FormulaDefinition(
            id: "F03",
            nameKey: "formula.f03.name",
            shortNameKey: "formula.f03.short",
            descriptionKey: "formula.f03.description",
            formulaExpressionKey: "formula.f03.expression",
            category: .sipAndMF,
            sfSymbol: "calendar.badge.plus",
            inputs: [
                input("monthly", "input.monthly_sip_amount", "unit.currency", "placeholder.monthly_sip_amount"),
                input("annualReturn", "input.expected_return", "unit.percent_pa", "placeholder.expected_return", defaultValue: "12"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 3
        ),
        FormulaDefinition(
            id: "F04",
            nameKey: "formula.f04.name",
            shortNameKey: "formula.f04.short",
            descriptionKey: "formula.f04.description",
            formulaExpressionKey: "formula.f04.expression",
            category: .sipAndMF,
            sfSymbol: "arrow.up.right",
            inputs: [
                input("investment", "input.investment_amount", "unit.currency", "placeholder.investment_amount"),
                input("annualReturn", "input.expected_return", "unit.percent_pa", "placeholder.expected_return"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 4
        ),
        FormulaDefinition(
            id: "F05",
            nameKey: "formula.f05.name",
            shortNameKey: "formula.f05.short",
            descriptionKey: "formula.f05.description",
            formulaExpressionKey: "formula.f05.expression",
            category: .returns,
            sfSymbol: "percent",
            inputs: [
                input("initial", "input.initial_investment", "unit.currency", "placeholder.initial_investment"),
                input("final", "input.final_value", "unit.currency", "placeholder.final_value")
            ],
            isPriority: true,
            displayOrder: 5
        ),
        FormulaDefinition(
            id: "F06",
            nameKey: "formula.f06.name",
            shortNameKey: "formula.f06.short",
            descriptionKey: "formula.f06.description",
            formulaExpressionKey: "formula.f06.expression",
            category: .returns,
            sfSymbol: "chart.line.uptrend.xyaxis",
            inputs: [
                input("beginning", "input.beginning_value", "unit.currency", "placeholder.beginning_value"),
                input("ending", "input.ending_value", "unit.currency", "placeholder.ending_value"),
                input("years", "input.years", "unit.years", "placeholder.years")
            ],
            isPriority: true,
            displayOrder: 6
        ),
        FormulaDefinition(
            id: "F07",
            nameKey: "formula.f07.name",
            shortNameKey: "formula.f07.short",
            descriptionKey: "formula.f07.description",
            formulaExpressionKey: "formula.f07.expression",
            category: .valuation,
            sfSymbol: "gauge.with.dots.needle.bottom.50percent",
            inputs: [
                input("marketPrice", "input.market_price", "unit.currency", "placeholder.market_price"),
                input("eps", "input.eps", "unit.currency", "placeholder.eps")
            ],
            isPriority: false,
            displayOrder: 7
        ),
        FormulaDefinition(
            id: "F08",
            nameKey: "formula.f08.name",
            shortNameKey: "formula.f08.short",
            descriptionKey: "formula.f08.description",
            formulaExpressionKey: "formula.f08.expression",
            category: .fundamental,
            sfSymbol: "function",
            inputs: [
                input("netIncome", "input.net_income", "unit.currency", "placeholder.net_income"),
                input("preferredDividends", "input.preferred_dividends", "unit.currency", "placeholder.preferred_dividends"),
                input("sharesOutstanding", "input.shares_outstanding", "unit.shares", "placeholder.shares_outstanding")
            ],
            isPriority: false,
            displayOrder: 8
        ),
        FormulaDefinition(
            id: "F09",
            nameKey: "formula.f09.name",
            shortNameKey: "formula.f09.short",
            descriptionKey: "formula.f09.description",
            formulaExpressionKey: "formula.f09.expression",
            category: .fundamental,
            sfSymbol: "arrow.triangle.2.circlepath",
            inputs: [
                input("netIncome", "input.net_income", "unit.currency", "placeholder.net_income"),
                input("equity", "input.shareholders_equity", "unit.currency", "placeholder.shareholders_equity")
            ],
            isPriority: false,
            displayOrder: 9
        ),
        FormulaDefinition(
            id: "F10",
            nameKey: "formula.f10.name",
            shortNameKey: "formula.f10.short",
            descriptionKey: "formula.f10.description",
            formulaExpressionKey: "formula.f10.expression",
            category: .valuation,
            sfSymbol: "dollarsign.circle",
            inputs: [
                input("dividend", "input.annual_dividend_per_share", "unit.currency", "placeholder.annual_dividend_per_share"),
                input("price", "input.share_price", "unit.currency", "placeholder.share_price")
            ],
            isPriority: false,
            displayOrder: 10
        ),
        FormulaDefinition(
            id: "F11",
            nameKey: "formula.f11.name",
            shortNameKey: "formula.f11.short",
            descriptionKey: "formula.f11.description",
            formulaExpressionKey: "formula.f11.expression",
            category: .fundamental,
            sfSymbol: "chart.bar",
            inputs: [
                input("netProfit", "input.net_profit", "unit.currency", "placeholder.net_profit"),
                input("revenue", "input.revenue", "unit.currency", "placeholder.revenue")
            ],
            isPriority: false,
            displayOrder: 11
        ),
        FormulaDefinition(
            id: "F12",
            nameKey: "formula.f12.name",
            shortNameKey: "formula.f12.short",
            descriptionKey: "formula.f12.description",
            formulaExpressionKey: "formula.f12.expression",
            category: .fundamental,
            sfSymbol: "scale.3d",
            inputs: [
                input("liabilities", "input.total_liabilities", "unit.currency", "placeholder.total_liabilities"),
                input("equity", "input.shareholders_equity", "unit.currency", "placeholder.shareholders_equity")
            ],
            isPriority: false,
            displayOrder: 12
        ),
        FormulaDefinition(
            id: "F13",
            nameKey: "formula.f13.name",
            shortNameKey: "formula.f13.short",
            descriptionKey: "formula.f13.description",
            formulaExpressionKey: "formula.f13.expression",
            category: .returns,
            sfSymbol: "chart.xyaxis.line",
            inputs: [
                input("buyPrice", "input.buy_price", "unit.currency", "placeholder.buy_price"),
                input("sellPrice", "input.sell_price", "unit.currency", "placeholder.sell_price"),
                input("dividends", "input.dividends_received", "unit.currency", "placeholder.dividends_received")
            ],
            isPriority: false,
            displayOrder: 13
        ),
        FormulaDefinition(
            id: "F14",
            nameKey: "formula.f14.name",
            shortNameKey: "formula.f14.short",
            descriptionKey: "formula.f14.description",
            formulaExpressionKey: "formula.f14.expression",
            category: .returns,
            sfSymbol: "hourglass",
            inputs: [
                input("initialValue", "input.initial_value", "unit.currency", "placeholder.initial_value"),
                input("endValue", "input.end_value", "unit.currency", "placeholder.end_value"),
                input("income", "input.income", "unit.currency", "placeholder.income")
            ],
            isPriority: false,
            displayOrder: 14
        ),
        FormulaDefinition(
            id: "F15",
            nameKey: "formula.f15.name",
            shortNameKey: "formula.f15.short",
            descriptionKey: "formula.f15.description",
            formulaExpressionKey: "formula.f15.expression",
            category: .returns,
            sfSymbol: "calendar",
            inputs: [
                input("totalReturn", "input.total_return", "unit.percent", "placeholder.total_return"),
                input("years", "input.years", "unit.years", "placeholder.years")
            ],
            isPriority: false,
            displayOrder: 15
        ),
        FormulaDefinition(
            id: "F16",
            nameKey: "formula.f16.name",
            shortNameKey: "formula.f16.short",
            descriptionKey: "formula.f16.description",
            formulaExpressionKey: "formula.f16.expression",
            category: .returns,
            sfSymbol: "sum",
            inputs: [
                input("invested", "input.invested_amount", "unit.currency", "placeholder.invested_amount"),
                input("current", "input.current_value", "unit.currency", "placeholder.current_value")
            ],
            isPriority: false,
            displayOrder: 16
        ),
        FormulaDefinition(
            id: "F17",
            nameKey: "formula.f17.name",
            shortNameKey: "formula.f17.short",
            descriptionKey: "formula.f17.description",
            formulaExpressionKey: "formula.f17.expression",
            category: .returns,
            sfSymbol: "thermometer.medium",
            inputs: [
                input("nominal", "input.nominal_return", "unit.percent", "placeholder.nominal_return"),
                input("inflation", "input.inflation_rate", "unit.percent", "placeholder.inflation_rate")
            ],
            isPriority: false,
            displayOrder: 17
        ),
        FormulaDefinition(
            id: "F18",
            nameKey: "formula.f18.name",
            shortNameKey: "formula.f18.short",
            descriptionKey: "formula.f18.description",
            formulaExpressionKey: "formula.f18.expression",
            category: .valuation,
            sfSymbol: "book",
            inputs: [
                input("marketPrice", "input.market_price", "unit.currency", "placeholder.market_price"),
                input("bookValue", "input.book_value_per_share", "unit.currency", "placeholder.book_value_per_share")
            ],
            isPriority: false,
            displayOrder: 18
        ),
        FormulaDefinition(
            id: "F19",
            nameKey: "formula.f19.name",
            shortNameKey: "formula.f19.short",
            descriptionKey: "formula.f19.description",
            formulaExpressionKey: "formula.f19.expression",
            category: .valuation,
            sfSymbol: "dial.medium",
            inputs: [
                input("pe", "input.pe_ratio", "unit.multiple", "placeholder.pe_ratio"),
                input("growth", "input.eps_growth_rate", "unit.percent", "placeholder.eps_growth_rate")
            ],
            isPriority: false,
            displayOrder: 19
        ),
        FormulaDefinition(
            id: "F20",
            nameKey: "formula.f20.name",
            shortNameKey: "formula.f20.short",
            descriptionKey: "formula.f20.description",
            formulaExpressionKey: "formula.f20.expression",
            category: .valuation,
            sfSymbol: "building.2",
            inputs: [
                input("marketCap", "input.market_cap", "unit.currency", "placeholder.market_cap"),
                input("debt", "input.total_debt", "unit.currency", "placeholder.total_debt"),
                input("cash", "input.cash", "unit.currency", "placeholder.cash"),
                input("ebitda", "input.ebitda", "unit.currency", "placeholder.ebitda")
            ],
            isPriority: false,
            displayOrder: 20
        ),
        FormulaDefinition(
            id: "F21",
            nameKey: "formula.f21.name",
            shortNameKey: "formula.f21.short",
            descriptionKey: "formula.f21.description",
            formulaExpressionKey: "formula.f21.expression",
            category: .valuation,
            sfSymbol: "building.columns.circle",
            inputs: [
                input("eps", "input.eps", "unit.currency", "placeholder.eps"),
                input("growth", "input.expected_growth_rate", "unit.percent", "placeholder.expected_growth_rate"),
                input("yield", "input.aaa_bond_yield", "unit.percent", "placeholder.aaa_bond_yield"),
                input("marketPrice", "input.current_market_price", "unit.currency", "placeholder.current_market_price", optional: true)
            ],
            isPriority: false,
            displayOrder: 21
        ),
        FormulaDefinition(
            id: "F22",
            nameKey: "formula.f22.name",
            shortNameKey: "formula.f22.short",
            descriptionKey: "formula.f22.description",
            formulaExpressionKey: "formula.f22.expression",
            category: .valuation,
            sfSymbol: "water.waves",
            inputs: [
                input("cashFlow", "input.annual_cash_flow", "unit.currency", "placeholder.annual_cash_flow"),
                input("discount", "input.discount_rate", "unit.percent", "placeholder.discount_rate"),
                input("years", "input.years", "unit.years", "placeholder.years")
            ],
            isPriority: false,
            displayOrder: 22
        ),
        FormulaDefinition(
            id: "F23",
            nameKey: "formula.f23.name",
            shortNameKey: "formula.f23.short",
            descriptionKey: "formula.f23.description",
            formulaExpressionKey: "formula.f23.expression",
            category: .valuation,
            sfSymbol: "arrow.up.forward.circle",
            inputs: [
                input("eps", "input.eps", "unit.currency", "placeholder.eps"),
                input("marketPrice", "input.market_price", "unit.currency", "placeholder.market_price")
            ],
            isPriority: false,
            displayOrder: 23
        ),
        FormulaDefinition(
            id: "F24",
            nameKey: "formula.f24.name",
            shortNameKey: "formula.f24.short",
            descriptionKey: "formula.f24.description",
            formulaExpressionKey: "formula.f24.expression",
            category: .valuation,
            sfSymbol: "chart.pie",
            inputs: [
                input("dividend", "input.annual_dividend_per_share", "unit.currency", "placeholder.annual_dividend_per_share"),
                input("eps", "input.eps", "unit.currency", "placeholder.eps")
            ],
            isPriority: false,
            displayOrder: 24
        ),
        FormulaDefinition(
            id: "F25",
            nameKey: "formula.f25.name",
            shortNameKey: "formula.f25.short",
            descriptionKey: "formula.f25.description",
            formulaExpressionKey: "formula.f25.expression",
            category: .risk,
            sfSymbol: "speedometer",
            inputs: [
                input("portfolioReturn", "input.portfolio_return", "unit.percent", "placeholder.portfolio_return"),
                input("riskFree", "input.risk_free_rate", "unit.percent", "placeholder.risk_free_rate"),
                input("stdDev", "input.std_deviation", "unit.percent", "placeholder.std_deviation")
            ],
            isPriority: false,
            displayOrder: 25
        ),
        FormulaDefinition(
            id: "F26",
            nameKey: "formula.f26.name",
            shortNameKey: "formula.f26.short",
            descriptionKey: "formula.f26.description",
            formulaExpressionKey: "formula.f26.expression",
            category: .portfolio,
            sfSymbol: "chart.pie.fill",
            inputs: [
                input("weight", "input.weight", "unit.percent", "placeholder.weight", dynamic: true),
                input("return", "input.return", "unit.percent", "placeholder.return", dynamic: true)
            ],
            isPriority: false,
            displayOrder: 26
        ),
        FormulaDefinition(
            id: "F27",
            nameKey: "formula.f27.name",
            shortNameKey: "formula.f27.short",
            descriptionKey: "formula.f27.description",
            formulaExpressionKey: "formula.f27.expression",
            category: .portfolio,
            sfSymbol: "chart.line.uptrend.xyaxis",
            inputs: [
                input("weight", "input.weight", "unit.percent", "placeholder.weight", dynamic: true),
                input("beta", "input.beta", "unit.multiple", "placeholder.beta", dynamic: true)
            ],
            isPriority: false,
            displayOrder: 27
        ),
        FormulaDefinition(
            id: "F28",
            nameKey: "formula.f28.name",
            shortNameKey: "formula.f28.short",
            descriptionKey: "formula.f28.description",
            formulaExpressionKey: "formula.f28.expression",
            category: .risk,
            sfSymbol: "dot.scope",
            inputs: [
                input("stockReturn", "input.stock_return", "unit.percent", "placeholder.stock_return"),
                input("marketReturn", "input.market_return", "unit.percent", "placeholder.market_return"),
                input("riskFree", "input.risk_free_rate", "unit.percent", "placeholder.risk_free_rate")
            ],
            isPriority: false,
            displayOrder: 28
        ),
        FormulaDefinition(
            id: "F29",
            nameKey: "formula.f29.name",
            shortNameKey: "formula.f29.short",
            descriptionKey: "formula.f29.description",
            formulaExpressionKey: "formula.f29.expression",
            category: .risk,
            sfSymbol: "a.circle",
            inputs: [
                input("actualReturn", "input.actual_return", "unit.percent", "placeholder.actual_return"),
                input("riskFree", "input.risk_free_rate", "unit.percent", "placeholder.risk_free_rate"),
                input("beta", "input.beta", "unit.multiple", "placeholder.beta"),
                input("marketReturn", "input.market_return", "unit.percent", "placeholder.market_return")
            ],
            isPriority: false,
            displayOrder: 29
        ),
        FormulaDefinition(
            id: "F30",
            nameKey: "formula.f30.name",
            shortNameKey: "formula.f30.short",
            descriptionKey: "formula.f30.description",
            formulaExpressionKey: "formula.f30.expression",
            category: .risk,
            sfSymbol: "bell.badge",
            inputs: [
                input("returns", "input.periodic_return", "unit.percent", "placeholder.periodic_return", dynamic: true)
            ],
            isPriority: false,
            displayOrder: 30
        ),
        FormulaDefinition(
            id: "F31",
            nameKey: "formula.f31.name",
            shortNameKey: "formula.f31.short",
            descriptionKey: "formula.f31.description",
            formulaExpressionKey: "formula.f31.expression",
            category: .risk,
            sfSymbol: "shield.lefthalf.filled",
            inputs: [
                input("portfolioValue", "input.portfolio_value", "unit.currency", "placeholder.portfolio_value"),
                input("confidence", "input.confidence_level", "unit.percent", "placeholder.confidence_level", defaultValue: "95"),
                input("dailyVolatility", "input.daily_volatility", "unit.percent", "placeholder.daily_volatility"),
                input("days", "input.days", "unit.days", "placeholder.days")
            ],
            isPriority: false,
            displayOrder: 31
        ),
        FormulaDefinition(
            id: "F32",
            nameKey: "formula.f32.name",
            shortNameKey: "formula.f32.short",
            descriptionKey: "formula.f32.description",
            formulaExpressionKey: "formula.f32.expression",
            category: .risk,
            sfSymbol: "arrow.down.to.line",
            inputs: [
                input("portfolioValue", "input.portfolio_value_point", "unit.currency", "placeholder.portfolio_value_point", dynamic: true)
            ],
            isPriority: false,
            displayOrder: 32
        ),
        FormulaDefinition(
            id: "F33",
            nameKey: "formula.f33.name",
            shortNameKey: "formula.f33.short",
            descriptionKey: "formula.f33.description",
            formulaExpressionKey: "formula.f33.expression",
            category: .technical,
            sfSymbol: "gauge.with.needle",
            inputs: [
                input("avgGain", "input.avg_gain", "unit.percent", "placeholder.avg_gain"),
                input("avgLoss", "input.avg_loss", "unit.percent", "placeholder.avg_loss"),
                input("period", "input.period", "unit.periods", "placeholder.period", defaultValue: "14")
            ],
            isPriority: false,
            displayOrder: 33
        ),
        FormulaDefinition(
            id: "F34",
            nameKey: "formula.f34.name",
            shortNameKey: "formula.f34.short",
            descriptionKey: "formula.f34.description",
            formulaExpressionKey: "formula.f34.expression",
            category: .technical,
            sfSymbol: "line.diagonal",
            inputs: [
                input("price", "input.price", "unit.currency", "placeholder.price", dynamic: true)
            ],
            isPriority: false,
            displayOrder: 34
        ),
        FormulaDefinition(
            id: "F35",
            nameKey: "formula.f35.name",
            shortNameKey: "formula.f35.short",
            descriptionKey: "formula.f35.description",
            formulaExpressionKey: "formula.f35.expression",
            category: .technical,
            sfSymbol: "waveform.path",
            inputs: [
                input("previousEMA", "input.previous_ema", "unit.currency", "placeholder.previous_ema"),
                input("currentPrice", "input.current_price", "unit.currency", "placeholder.current_price"),
                input("period", "input.period", "unit.periods", "placeholder.period")
            ],
            isPriority: false,
            displayOrder: 35
        ),
        FormulaDefinition(
            id: "F36",
            nameKey: "formula.f36.name",
            shortNameKey: "formula.f36.short",
            descriptionKey: "formula.f36.description",
            formulaExpressionKey: "formula.f36.expression",
            category: .technical,
            sfSymbol: "chart.bar.xaxis.ascending",
            inputs: [
                input("ema12", "input.ema12", "unit.currency", "placeholder.ema12"),
                input("ema26", "input.ema26", "unit.currency", "placeholder.ema26"),
                input("signalPrev", "input.previous_signal_line", "unit.currency", "placeholder.previous_signal_line")
            ],
            isPriority: false,
            displayOrder: 36
        ),
        FormulaDefinition(
            id: "F37",
            nameKey: "formula.f37.name",
            shortNameKey: "formula.f37.short",
            descriptionKey: "formula.f37.description",
            formulaExpressionKey: "formula.f37.expression",
            category: .technical,
            sfSymbol: "slider.horizontal.3",
            inputs: [
                input("sma", "input.sma", "unit.currency", "placeholder.sma"),
                input("stdDev", "input.std_deviation", "unit.currency", "placeholder.std_deviation"),
                input("multiplier", "input.multiplier", "unit.multiple", "placeholder.multiplier", defaultValue: "2")
            ],
            isPriority: false,
            displayOrder: 37
        ),
        FormulaDefinition(
            id: "F38",
            nameKey: "formula.f38.name",
            shortNameKey: "formula.f38.short",
            descriptionKey: "formula.f38.description",
            formulaExpressionKey: "formula.f38.expression",
            category: .technical,
            sfSymbol: "slider.horizontal.3",
            inputs: [
                input("close", "input.current_close", "unit.currency", "placeholder.current_close"),
                input("low", "input.lowest_low", "unit.currency", "placeholder.lowest_low"),
                input("high", "input.highest_high", "unit.currency", "placeholder.highest_high")
            ],
            isPriority: false,
            displayOrder: 38
        ),
        FormulaDefinition(
            id: "F39",
            nameKey: "formula.f39.name",
            shortNameKey: "formula.f39.short",
            descriptionKey: "formula.f39.description",
            formulaExpressionKey: "formula.f39.expression",
            category: .technical,
            sfSymbol: "line.3.horizontal.decrease.circle",
            inputs: [
                input("high", "input.previous_high", "unit.currency", "placeholder.previous_high"),
                input("low", "input.previous_low", "unit.currency", "placeholder.previous_low"),
                input("close", "input.previous_close", "unit.currency", "placeholder.previous_close")
            ],
            isPriority: false,
            displayOrder: 39
        ),
        FormulaDefinition(
            id: "F40",
            nameKey: "formula.f40.name",
            shortNameKey: "formula.f40.short",
            descriptionKey: "formula.f40.description",
            formulaExpressionKey: "formula.f40.expression",
            category: .fundamental,
            sfSymbol: "r.circle",
            inputs: [
                input("netIncome", "input.net_income", "unit.currency", "placeholder.net_income"),
                input("assets", "input.total_assets", "unit.currency", "placeholder.total_assets")
            ],
            isPriority: false,
            displayOrder: 40
        ),
        FormulaDefinition(
            id: "F41",
            nameKey: "formula.f41.name",
            shortNameKey: "formula.f41.short",
            descriptionKey: "formula.f41.description",
            formulaExpressionKey: "formula.f41.expression",
            category: .fundamental,
            sfSymbol: "drop",
            inputs: [
                input("currentAssets", "input.current_assets", "unit.currency", "placeholder.current_assets"),
                input("currentLiabilities", "input.current_liabilities", "unit.currency", "placeholder.current_liabilities")
            ],
            isPriority: false,
            displayOrder: 41
        ),
        FormulaDefinition(
            id: "F42",
            nameKey: "formula.f42.name",
            shortNameKey: "formula.f42.short",
            descriptionKey: "formula.f42.description",
            formulaExpressionKey: "formula.f42.expression",
            category: .fundamental,
            sfSymbol: "percent",
            inputs: [
                input("operatingIncome", "input.operating_income", "unit.currency", "placeholder.operating_income"),
                input("revenue", "input.revenue", "unit.currency", "placeholder.revenue")
            ],
            isPriority: false,
            displayOrder: 42
        ),
        FormulaDefinition(
            id: "F43",
            nameKey: "formula.f43.name",
            shortNameKey: "formula.f43.short",
            descriptionKey: "formula.f43.description",
            formulaExpressionKey: "formula.f43.expression",
            category: .fundamental,
            sfSymbol: "shippingbox",
            inputs: [
                input("revenue", "input.revenue", "unit.currency", "placeholder.revenue"),
                input("cogs", "input.cogs", "unit.currency", "placeholder.cogs")
            ],
            isPriority: false,
            displayOrder: 43
        ),
        FormulaDefinition(
            id: "F44",
            nameKey: "formula.f44.name",
            shortNameKey: "formula.f44.short",
            descriptionKey: "formula.f44.description",
            formulaExpressionKey: "formula.f44.expression",
            category: .fundamental,
            sfSymbol: "exclamationmark.shield",
            inputs: [
                input("ebit", "input.ebit", "unit.currency", "placeholder.ebit"),
                input("interestExpense", "input.interest_expense", "unit.currency", "placeholder.interest_expense")
            ],
            isPriority: false,
            displayOrder: 44
        ),
        FormulaDefinition(
            id: "F45",
            nameKey: "formula.f45.name",
            shortNameKey: "formula.f45.short",
            descriptionKey: "formula.f45.description",
            formulaExpressionKey: "formula.f45.expression",
            category: .fundamental,
            sfSymbol: "arrow.left.arrow.right",
            inputs: [
                input("sales", "input.net_sales", "unit.currency", "placeholder.net_sales"),
                input("beginAssets", "input.beginning_assets", "unit.currency", "placeholder.beginning_assets"),
                input("endAssets", "input.ending_assets", "unit.currency", "placeholder.ending_assets")
            ],
            isPriority: false,
            displayOrder: 45
        ),
        FormulaDefinition(
            id: "F46",
            nameKey: "formula.f46.name",
            shortNameKey: "formula.f46.short",
            descriptionKey: "formula.f46.description",
            formulaExpressionKey: "formula.f46.expression",
            category: .bonds,
            sfSymbol: "banknote",
            inputs: [
                input("coupon", "input.annual_coupon", "unit.currency", "placeholder.annual_coupon"),
                input("face", "input.face_value", "unit.currency", "placeholder.face_value"),
                input("price", "input.current_price", "unit.currency", "placeholder.current_price"),
                input("years", "input.years_to_maturity", "unit.years", "placeholder.years_to_maturity")
            ],
            isPriority: false,
            displayOrder: 46
        ),
        FormulaDefinition(
            id: "F47",
            nameKey: "formula.f47.name",
            shortNameKey: "formula.f47.short",
            descriptionKey: "formula.f47.description",
            formulaExpressionKey: "formula.f47.expression",
            category: .bonds,
            sfSymbol: "tag",
            inputs: [
                input("face", "input.face_value", "unit.currency", "placeholder.face_value"),
                input("couponRate", "input.coupon_rate", "unit.percent", "placeholder.coupon_rate"),
                input("marketRate", "input.market_rate", "unit.percent", "placeholder.market_rate"),
                input("years", "input.years", "unit.years", "placeholder.years")
            ],
            isPriority: false,
            displayOrder: 47
        ),
        FormulaDefinition(
            id: "F48",
            nameKey: "formula.f48.name",
            shortNameKey: "formula.f48.short",
            descriptionKey: "formula.f48.description",
            formulaExpressionKey: "formula.f48.expression",
            category: .bonds,
            sfSymbol: "percent",
            inputs: [
                input("couponPayment", "input.annual_coupon_payment", "unit.currency", "placeholder.annual_coupon_payment"),
                input("face", "input.face_value", "unit.currency", "placeholder.face_value")
            ],
            isPriority: false,
            displayOrder: 48
        ),
        FormulaDefinition(
            id: "F49",
            nameKey: "formula.f49.name",
            shortNameKey: "formula.f49.short",
            descriptionKey: "formula.f49.description",
            formulaExpressionKey: "formula.f49.expression",
            category: .options,
            sfSymbol: "flag.checkered",
            inputs: [
                input("strike", "input.strike_price", "unit.currency", "placeholder.strike_price"),
                input("premium", "input.premium_paid", "unit.currency", "placeholder.premium_paid"),
                input("isCall", "input.option_type", "unit.none", "placeholder.option_type")
            ],
            isPriority: false,
            displayOrder: 49
        ),
        FormulaDefinition(
            id: "F50",
            nameKey: "formula.f50.name",
            shortNameKey: "formula.f50.short",
            descriptionKey: "formula.f50.description",
            formulaExpressionKey: "formula.f50.expression",
            category: .options,
            sfSymbol: "checkmark.circle",
            inputs: [
                input("stock", "input.stock_price", "unit.currency", "placeholder.stock_price"),
                input("strike", "input.strike_price", "unit.currency", "placeholder.strike_price"),
                input("isCall", "input.option_type", "unit.none", "placeholder.option_type"),
                input("premium", "input.premium_paid", "unit.currency", "placeholder.premium_paid", optional: true)
            ],
            isPriority: false,
            displayOrder: 50
        ),
        FormulaDefinition(
            id: "F51",
            nameKey: "formula.f51.name",
            shortNameKey: "formula.f51.short",
            descriptionKey: "formula.f51.description",
            formulaExpressionKey: "formula.f51.expression",
            category: .options,
            sfSymbol: "equal.square",
            inputs: [
                input("callPrice", "input.call_price", "unit.currency", "placeholder.call_price", optional: true),
                input("putPrice", "input.put_price", "unit.currency", "placeholder.put_price", optional: true),
                input("stock", "input.stock_price", "unit.currency", "placeholder.stock_price"),
                input("strike", "input.strike_price", "unit.currency", "placeholder.strike_price"),
                input("riskFree", "input.risk_free_rate", "unit.percent", "placeholder.risk_free_rate"),
                input("time", "input.time_years", "unit.years", "placeholder.time_years")
            ],
            isPriority: false,
            displayOrder: 51
        ),
        FormulaDefinition(
            id: "F52",
            nameKey: "formula.f52.name",
            shortNameKey: "formula.f52.short",
            descriptionKey: "formula.f52.description",
            formulaExpressionKey: "formula.f52.expression",
            category: .options,
            sfSymbol: "function",
            inputs: [
                input("stock", "input.stock_price", "unit.currency", "placeholder.stock_price"),
                input("strike", "input.strike_price", "unit.currency", "placeholder.strike_price"),
                input("riskFree", "input.risk_free_rate", "unit.percent", "placeholder.risk_free_rate"),
                input("time", "input.time_years", "unit.years", "placeholder.time_years"),
                input("volatility", "input.volatility", "unit.percent", "placeholder.volatility")
            ],
            isPriority: false,
            displayOrder: 52
        ),
        FormulaDefinition(
            id: "F53",
            nameKey: "formula.f53.name",
            shortNameKey: "formula.f53.short",
            descriptionKey: "formula.f53.description",
            formulaExpressionKey: "formula.f53.expression",
            category: .risk,
            sfSymbol: "banknote.fill",
            inputs: [
                input("loanAmount", "input.loan_amount", "unit.currency", "placeholder.loan_amount"),
                input("annualRate", "input.annual_rate", "unit.percent_pa", "placeholder.annual_rate"),
                input("years", "input.loan_years", "unit.years", "placeholder.loan_years")
            ],
            isPriority: true,
            displayOrder: 53
        ),
        FormulaDefinition(
            id: "F54",
            nameKey: "formula.f54.name",
            shortNameKey: "formula.f54.short",
            descriptionKey: "formula.f54.description",
            formulaExpressionKey: "formula.f54.expression",
            category: .returns,
            sfSymbol: "clock.arrow.circlepath",
            inputs: [
                input("principal", "input.principal_amount", "unit.currency", "placeholder.principal_amount"),
                input("rate", "input.interest_rate", "unit.percent_pa", "placeholder.interest_rate"),
                input("years", "input.time_years", "unit.years", "placeholder.time_years")
            ],
            isPriority: false,
            displayOrder: 54
        ),
        FormulaDefinition(
            id: "F55",
            nameKey: "formula.f55.name",
            shortNameKey: "formula.f55.short",
            descriptionKey: "formula.f55.description",
            formulaExpressionKey: "formula.f55.expression",
            category: .returns,
            sfSymbol: "doc.text.magnifyingglass",
            inputs: [
                input("amount", "input.base_amount", "unit.currency", "placeholder.base_amount"),
                input("gstRate", "input.gst_rate", "unit.percent", "placeholder.gst_rate")
            ],
            isPriority: true,
            displayOrder: 55
        ),
        FormulaDefinition(
            id: "F56",
            nameKey: "formula.f56.name",
            shortNameKey: "formula.f56.short",
            descriptionKey: "formula.f56.description",
            formulaExpressionKey: "formula.f56.expression",
            category: .technical,
            sfSymbol: "tag.circle",
            inputs: [
                input("markedPrice", "input.marked_price", "unit.currency", "placeholder.marked_price"),
                input("sellingPrice", "input.selling_price", "unit.currency", "placeholder.selling_price")
            ],
            isPriority: false,
            displayOrder: 56
        ),
        FormulaDefinition(
            id: "F57",
            nameKey: "formula.f57.name",
            shortNameKey: "formula.f57.short",
            descriptionKey: "formula.f57.description",
            formulaExpressionKey: "formula.f57.expression",
            category: .sipAndMF,
            sfSymbol: "target",
            inputs: [
                input("target", "input.target_amount", "unit.currency", "placeholder.target_amount"),
                input("annualReturn", "input.expected_return", "unit.percent_pa", "placeholder.expected_return"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 57
        ),
        FormulaDefinition(
            id: "F58",
            nameKey: "formula.f58.name",
            shortNameKey: "formula.f58.short",
            descriptionKey: "formula.f58.description",
            formulaExpressionKey: "formula.f58.expression",
            category: .risk,
            sfSymbol: "house.and.flag.fill",
            inputs: [
                input("monthlyIncome", "input.monthly_income", "unit.currency", "placeholder.monthly_income"),
                input("foir", "input.foir_ratio", "unit.percent", "placeholder.foir_ratio", defaultValue: "45"),
                input("existingObligations", "input.existing_emi", "unit.currency", "placeholder.existing_emi", defaultValue: "0")
            ],
            isPriority: true,
            displayOrder: 58
        ),
        FormulaDefinition(
            id: "F59",
            nameKey: "formula.f59.name",
            shortNameKey: "formula.f59.short",
            descriptionKey: "formula.f59.description",
            formulaExpressionKey: "formula.f59.expression",
            category: .valuation,
            sfSymbol: "building.2.crop.circle",
            inputs: [
                input("monthlyRent", "input.monthly_rent", "unit.currency", "placeholder.monthly_rent"),
                input("propertyPrice", "input.property_price", "unit.currency", "placeholder.property_price")
            ],
            isPriority: false,
            displayOrder: 59
        ),
        FormulaDefinition(
            id: "F60",
            nameKey: "formula.f60.name",
            shortNameKey: "formula.f60.short",
            descriptionKey: "formula.f60.description",
            formulaExpressionKey: "formula.f60.expression",
            category: .technical,
            sfSymbol: "chart.bar.doc.horizontal",
            inputs: [
                input("fixedCost", "input.fixed_cost", "unit.currency", "placeholder.fixed_cost"),
                input("sellingPricePerUnit", "input.selling_price_per_unit", "unit.currency", "placeholder.selling_price_per_unit"),
                input("variableCostPerUnit", "input.variable_cost_per_unit", "unit.currency", "placeholder.variable_cost_per_unit")
            ],
            isPriority: true,
            displayOrder: 60
        ),
        FormulaDefinition(
            id: "F61",
            nameKey: "formula.f61.name",
            shortNameKey: "formula.f61.short",
            descriptionKey: "formula.f61.description",
            formulaExpressionKey: "formula.f61.expression",
            category: .technical,
            sfSymbol: "indianrupeesign.arrow.circlepath",
            inputs: [
                input("revenue", "input.revenue", "unit.currency", "placeholder.revenue"),
                input("cogs", "input.cogs", "unit.currency", "placeholder.cogs")
            ],
            isPriority: false,
            displayOrder: 61
        ),
        FormulaDefinition(
            id: "F62",
            nameKey: "formula.f62.name",
            shortNameKey: "formula.f62.short",
            descriptionKey: "formula.f62.description",
            formulaExpressionKey: "formula.f62.expression",
            category: .fundamental,
            sfSymbol: "shield.lefthalf.filled",
            inputs: [
                input("monthlyExpense", "input.monthly_expense", "unit.currency", "placeholder.monthly_expense"),
                input("months", "input.coverage_months", "unit.months", "placeholder.coverage_months", defaultValue: "6")
            ],
            isPriority: true,
            displayOrder: 62
        ),
        FormulaDefinition(
            id: "F63",
            nameKey: "formula.f63.name",
            shortNameKey: "formula.f63.short",
            descriptionKey: "formula.f63.description",
            formulaExpressionKey: "formula.f63.expression",
            category: .fundamental,
            sfSymbol: "figure.run.circle",
            inputs: [
                input("annualExpense", "input.annual_expense", "unit.currency", "placeholder.annual_expense"),
                input("withdrawalRate", "input.withdrawal_rate", "unit.percent", "placeholder.withdrawal_rate", defaultValue: "4")
            ],
            isPriority: true,
            displayOrder: 63
        ),
        FormulaDefinition(
            id: "F64",
            nameKey: "formula.f64.name",
            shortNameKey: "formula.f64.short",
            descriptionKey: "formula.f64.description",
            formulaExpressionKey: "formula.f64.expression",
            category: .returns,
            sfSymbol: "sum",
            inputs: [
                input("annualReturn", "input.expected_return", "unit.percent_pa", "placeholder.expected_return")
            ],
            isPriority: false,
            displayOrder: 64
        ),
        FormulaDefinition(
            id: "F65",
            nameKey: "formula.f65.name",
            shortNameKey: "formula.f65.short",
            descriptionKey: "formula.f65.description",
            formulaExpressionKey: "formula.f65.expression",
            category: .returns,
            sfSymbol: "clock.badge.exclamationmark",
            inputs: [
                input("currentCost", "input.current_cost", "unit.currency", "placeholder.current_cost"),
                input("inflation", "input.inflation_rate", "unit.percent", "placeholder.inflation_rate", defaultValue: "6"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 65
        ),
        FormulaDefinition(
            id: "F66",
            nameKey: "formula.f66.name",
            shortNameKey: "formula.f66.short",
            descriptionKey: "formula.f66.description",
            formulaExpressionKey: "formula.f66.expression",
            category: .taxation,
            sfSymbol: "receipt",
            inputs: [
                input("gainAmount", "input.gain_amount", "unit.currency", "placeholder.gain_amount"),
                input("taxRate", "input.tax_rate", "unit.percent", "placeholder.tax_rate", defaultValue: "15")
            ],
            isPriority: true,
            displayOrder: 66
        ),
        FormulaDefinition(
            id: "F67",
            nameKey: "formula.f67.name",
            shortNameKey: "formula.f67.short",
            descriptionKey: "formula.f67.description",
            formulaExpressionKey: "formula.f67.expression",
            category: .taxation,
            sfSymbol: "wallet.pass",
            inputs: [
                input("grossIncome", "input.gross_income", "unit.currency", "placeholder.gross_income"),
                input("effectiveTaxRate", "input.effective_tax_rate", "unit.percent", "placeholder.effective_tax_rate", defaultValue: "20")
            ],
            isPriority: true,
            displayOrder: 67
        ),
        FormulaDefinition(
            id: "F68",
            nameKey: "formula.f68.name",
            shortNameKey: "formula.f68.short",
            descriptionKey: "formula.f68.description",
            formulaExpressionKey: "formula.f68.expression",
            category: .taxation,
            sfSymbol: "arrow.up.right.circle",
            inputs: [
                input("targetNetIncome", "input.target_net_income", "unit.currency", "placeholder.target_net_income"),
                input("effectiveTaxRate", "input.effective_tax_rate", "unit.percent", "placeholder.effective_tax_rate", defaultValue: "20")
            ],
            isPriority: false,
            displayOrder: 68
        ),
        FormulaDefinition(
            id: "F69",
            nameKey: "formula.f69.name",
            shortNameKey: "formula.f69.short",
            descriptionKey: "formula.f69.description",
            formulaExpressionKey: "formula.f69.expression",
            category: .planning,
            sfSymbol: "chart.pie",
            inputs: [
                input("monthlyDebt", "input.monthly_debt", "unit.currency", "placeholder.monthly_debt"),
                input("monthlyIncome", "input.monthly_income", "unit.currency", "placeholder.monthly_income")
            ],
            isPriority: true,
            displayOrder: 69
        ),
        FormulaDefinition(
            id: "F70",
            nameKey: "formula.f70.name",
            shortNameKey: "formula.f70.short",
            descriptionKey: "formula.f70.description",
            formulaExpressionKey: "formula.f70.expression",
            category: .planning,
            sfSymbol: "chart.bar.doc.horizontal",
            inputs: [
                input("monthlySavings", "input.monthly_savings", "unit.currency", "placeholder.monthly_savings"),
                input("monthlyIncome", "input.monthly_income", "unit.currency", "placeholder.monthly_income")
            ],
            isPriority: true,
            displayOrder: 70
        ),
        FormulaDefinition(
            id: "F71",
            nameKey: "formula.f71.name",
            shortNameKey: "formula.f71.short",
            descriptionKey: "formula.f71.description",
            formulaExpressionKey: "formula.f71.expression",
            category: .planning,
            sfSymbol: "scalemass",
            inputs: [
                input("totalAssets", "input.total_assets", "unit.currency", "placeholder.total_assets"),
                input("totalLiabilities", "input.total_liabilities", "unit.currency", "placeholder.total_liabilities")
            ],
            isPriority: false,
            displayOrder: 71
        ),
        FormulaDefinition(
            id: "F72",
            nameKey: "formula.f72.name",
            shortNameKey: "formula.f72.short",
            descriptionKey: "formula.f72.description",
            formulaExpressionKey: "formula.f72.expression",
            category: .planning,
            sfSymbol: "hourglass.bottomhalf.filled",
            inputs: [
                input("cashReserve", "input.cash_reserve", "unit.currency", "placeholder.cash_reserve"),
                input("monthlyExpense", "input.monthly_expense", "unit.currency", "placeholder.monthly_expense")
            ],
            isPriority: false,
            displayOrder: 72
        ),
        FormulaDefinition(
            id: "F73",
            nameKey: "formula.f73.name",
            shortNameKey: "formula.f73.short",
            descriptionKey: "formula.f73.description",
            formulaExpressionKey: "formula.f73.expression",
            category: .returns,
            sfSymbol: "flag.checkered.2.crossed",
            inputs: [
                input("currentAmount", "input.current_amount", "unit.currency", "placeholder.current_amount"),
                input("targetAmount", "input.target_amount", "unit.currency", "placeholder.target_amount"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 73
        ),
        FormulaDefinition(
            id: "F74",
            nameKey: "formula.f74.name",
            shortNameKey: "formula.f74.short",
            descriptionKey: "formula.f74.description",
            formulaExpressionKey: "formula.f74.expression",
            category: .risk,
            sfSymbol: "creditcard.and.123",
            inputs: [
                input("loanAmount", "input.loan_amount", "unit.currency", "placeholder.loan_amount"),
                input("annualRate", "input.annual_rate", "unit.percent_pa", "placeholder.annual_rate"),
                input("years", "input.loan_years", "unit.years", "placeholder.loan_years"),
                input("extraEMI", "input.extra_emi", "unit.currency", "placeholder.extra_emi", defaultValue: "0")
            ],
            isPriority: true,
            displayOrder: 74
        ),
        FormulaDefinition(
            id: "F75",
            nameKey: "formula.f75.name",
            shortNameKey: "formula.f75.short",
            descriptionKey: "formula.f75.description",
            formulaExpressionKey: "formula.f75.expression",
            category: .planning,
            sfSymbol: "indianrupeesign.ring",
            inputs: [
                input("corpus", "input.corpus", "unit.currency", "placeholder.corpus"),
                input("annualReturn", "input.expected_return", "unit.percent_pa", "placeholder.expected_return"),
                input("years", "input.time_period_years", "unit.years", "placeholder.time_period_years")
            ],
            isPriority: true,
            displayOrder: 75
        ),
        FormulaDefinition(
            id: "F76",
            nameKey: "formula.f76.name",
            shortNameKey: "formula.f76.short",
            descriptionKey: "formula.f76.description",
            formulaExpressionKey: "formula.f76.expression",
            category: .taxation,
            sfSymbol: "scale.3d",
            inputs: [
                input("grossSalary", "input.annual_gross_salary", "unit.currency", "placeholder.annual_gross_salary"),
                input("standardDeduction", "input.standard_deduction", "unit.currency", "placeholder.standard_deduction", optional: true, defaultValue: "50000"),
                input("hraExemption", "input.hra_exemption", "unit.currency", "placeholder.hra_exemption", optional: true),
                input("section80C", "input.section_80c", "unit.currency", "placeholder.section_80c", optional: true),
                input("section80D", "input.section_80d", "unit.currency", "placeholder.section_80d", optional: true),
                input("nps80ccd1b", "input.nps_80ccd_1b", "unit.currency", "placeholder.nps_80ccd_1b", optional: true),
                input("homeLoan24b", "input.home_loan_24b", "unit.currency", "placeholder.home_loan_24b", optional: true),
                input("otherDeductions", "input.other_deductions", "unit.currency", "placeholder.other_deductions", optional: true)
            ],
            isPriority: true,
            displayOrder: 76
        )
    ]

    static let featured: [FormulaDefinition] = all.filter { ["F01", "F02", "F03"].contains($0.id) }

    static func marketSorted(_ formulas: [FormulaDefinition]) -> [FormulaDefinition] {
        formulas.sorted { lhs, rhs in
            if lhs.isPriority != rhs.isPriority {
                return lhs.isPriority && !rhs.isPriority
            }
            if lhs.category.displayOrder != rhs.category.displayOrder {
                return lhs.category.displayOrder < rhs.category.displayOrder
            }
            if lhs.displayOrder != rhs.displayOrder {
                return lhs.displayOrder < rhs.displayOrder
            }
            return lhs.id < rhs.id
        }
    }
}
