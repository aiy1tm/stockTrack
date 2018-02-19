# stockTrack
iOS / Obj - C app that tracks stock positions using free Quandl stock price tables / calculates financial outlook based on budget-savings-network inputs

Requires CorePlot cocoapod as dependency.

This app fetches data from the make WIKI datatable from Quandl.

It used to fetch from Quandl's other free mutual fund / index databases as well, and search through them sequentially for a given ticker request. Those databases are no more, so those requests just silently fail and only the US-traded stocks go through correctly.

There are unimplemented features, like scheduled buying for long term tracking (or for backtests).
