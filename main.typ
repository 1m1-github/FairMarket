#import "template.typ": *
#show: ams-article.with(
  title: "2i2i ~ the provably fairest and most inclusive market model",
  authors: (
    (
      name: "1m1",
      email: "email@1m1.io",
    ),
  ),
  abstract: "This paper describes a novel, multi-dimensional, infinitely inclusive market model. The described model yields infinite types of new market dynamics and traditional markets as special cases, based on very few parameters. As the market allows any supply of arbitrarily small or large value to be traded in any currency, incl. subjective value currencies, any resulting liquid market must then find the fairest value of the supply.",
  bibliography-file: "refs.bib",
)

= Definitions

== Market

Assume we have a _seller_ with a finite _supply_ $SS$ and there exists a _demand_ $DD$ consisting of #emph[bid]s.

//A _market_ $MM$ is a function that determines the *next* _bid_ to be #link()[serviced]. Formally,

$ MM(SS, DD) = B $

where $B in DD$ is a _bid_.


More generally, we add a parameter to the _market_ $MM$ to output the _bid_ *next after* some given _bid_ $B$.

$ MM(SS, DD, B) = B#sub[next] $

$ B, B#sub[next] in DD union nothing $

$nothing$ represents an end, as follows. Simplifying $MM(SS, DD, B)$ to $MM(B)$,

$ MM(nothing) = B#sub[first] $
$ MM(B#sub[last]) = nothing $

This then allows for an ordering of the #emph[bid]s

$ DD = [B#sub[1], ..., B#sub[N]] = [MM^1(nothing), MM^2(nothing), ..., MM^N(nothing)] = [MM#super[rank] (nothing)]_(op("rank")=1)^N $

//In this paper, we will define a partial ordering and a total ordering that is _[fairest](https://github.com/2i2i///whitepaper/blob/main/Notes.md#fairest)_, most _[inclusive](https://github.com/2i2i/whitepaper/blob/main/Notes.md#most-inclusive)_ and accomodates [all](https://github.com/2i2i/whitepaper/blob/main/Notes.md#all-markets) types of #emph[market]s, as well as innovating new types of _market_s with a generic framework.

== Parameters

The _seller_ sets the following _parameters_ $PP$:

$ PP = (#underline[M], II) $

$ #underline[M] gt.eq 0 op(" minimum value of the supply") $

$ II = op("importance") $

The _importance_ $II$ will be explained later. It is a setting of the _seller_ defining the importance of the different categories of #emph[bid]s.

== Bid

Each _bid_ $B$ looks as follows:

$ B = (T, A, PP) $

$ T = op("time of creation") $

$ A = (q, op("ccy"), op("FX")) op(" is the amount of the bid") $

$ PP = op(" the sellers parameters at time ") T $

The _amount_ $A$ contains a quantity $q$, a _currency_ $op("ccy")$ and an exchange rate to a _base currency_ $op("FX")$, all fixed at time $T$.


== Currency and FX

#let FX = "FX"
#let ccy = "ccy"
#let obj = "obj"
#let subj = "subj"
#let base = "base"

//Let $CC$ be the universe of all existing [currencies](https://github.com/2i2i/whitepaper/blob/main/Notes.md#currency).

Then

$ CC = CC_obj union.dot CC_subj $

//that is, any _currency_ either has [objective value xor subjective value](https://github.com/2i2i/whitepaper/blob/main/Notes.md#objective-vs-subjective-value).

We choose some

$ ccy_base in CC_obj $

as the _base currency_ and we define

$ FX(ccy) = FX(ccy, T) = FX(ccy, ccy_base, T) $

as the _fair_ exchange rate between $ccy$ and $ccy_base$, i.e.

$ 1 [ccy] = FX(ccy) [ccy_base] $

and

$ FX(ccy) = nothing op(" if") ccy in CC_subj $


Before we categorize the #emph[bid]s, let's simplify them. First, we call a _bid_ $B$ _objective_

$ B op(" is objective") arrow.l.r.double ccy in CC_obj $

if it is of an objective value currency.


The _amount_ $A$ of each _objective_ _bid_ can be transformed into the chosen _base currency_, as follows:

$ B(T, A = (q, ccy, FX), PP) arrow.r B_base(T, A = (FX dot.op q , ccy_base, FX ident.strict 1), PP) $

//> This means, without loss of generality, we can [assume](https://github.com/2i2i/whitepaper/blob/main/Notes.md#assuming) all _objective bids_ to be denominated in the _base currency_.

== _Bid_ Categories

#let chrony = "chrony"
#let CHR = "CHR"
#let highroller = "highroller"
#let HR = "HR"
#let lurker = "lurker"
#let LURK = "LURK"
#let subjective = "subjective"
#let SUBJ = "SUBJ"
#let BC = "BC"

// [Assuming](https://github.com/2i2i/whitepaper/blob/main/Notes.md#assuming) that the _min_ value $\underline{M}$ is also in the _base currency_, we [define](https://github.com/2i2i/whitepaper/blob/main/Notes.md#practical-chrony) the following 4 _bid_ categories:

$ chrony (bold(CHR)) arrow.l.r.double B op(" is objective and ") q = underline(M) $
$ highroller (bold(HR)) arrow.l.r.double B op(" is objective and ") q > underline(M) $
$ lurker (bold(LURK)) arrow.l.r.double B op(" is objective and ") q < underline(M) $
$ subjective (bold(SUBJ)) arrow.l.r.double B op(" is subjective") $

We can denote a _bid_ $B$'s _category_ as $BC(B)$.

== _Importance_

The _seller_ defines the _importance_ per _bid_ _category_

$ II = (II_CHR, II_HR, II_LURK, II_SUBJ) $

where each _importace_ is a natural number

$ II_x in NN_(gt.eq 0), x in {CHR, HR, LURK, SUBJ} $

the market is activated
$ 0 < sum_x II_x =: sum II $

// and the _[lurkers](https://github.com/2i2i/whitepaper/blob/main/Notes.md#why-lurkers)_ never get serviced

$ II_LURK = 0 $


Amongst every subsequence of the ordered #emph[bid]s $[B_n, ..., B_m]$ of length $sum II$, on average, we get $II_x$ many of _bid_ _category_ $x$.

E.g. if

$ II = (II_CHR = 2, II_HR = 3, II_LURK = 0, II_SUBJ = 1) $

then, on average, any subsequence of 6 #emph[bid]s _serviced_ should contain 2 _chrony_, 3 _highroller_ #emph[bid]s and 1 _subjective_ _bid_.

= the market $MM$

== Characteristics

We want to create a _market_ function such that:

- _importance_ is respected

//- order of _objective_ #emph[bid]s is objectively [deterministic](https://github.com/2i2i/whitepaper/blob/main/Notes.md#deterministic)

- internal category order is maintained

// - worst case _rank_ for _chrony_ _bids_ is [finite](https://github.com/2i2i/whitepaper/blob/main/Notes.md#chrony-only-worst-case-finite)

- the _seller_ can use it's own subjective value function to value #emph[subjective bid]s

== Internal category order

//_Chrony_ #emph[bid]s are _time_ ordered, _highroller_ _bids_ are _value_ ordered, _subjective_ #emph[bid]s are ordered by each _seller_ *subjectively* and _lurker_ #emph[bid]s live in the [projective infinity](https://github.com/2i2i/whitepaper/blob/main/Notes.md#projective-infinity), never serviced.

== Traditional #emph[market]s as special cases

=== Fixed price

$ underline(M) = op("fixed price") $

$ II = (II_CHR = 1, II_HR = 0, II_LURK = 0, II_SUBJ = 0) $

=== Auction

$ underline(M) = op("min price") $

$ II = (II_CHR = 0, II_HR = 1, II_LURK = 0, II_SUBJ = 0) $

==== Barter

$ II = (II_CHR = 0, II_HR = 0, II_LURK = 0, II_SUBJ = 1) $

==== All other cases are mixed, innovative #emph[market]s and can yield differing dynamics.


== The algorithm

=== 1. Sort the #emph[bid]s

We can almost surely assume

$ T_i eq.not T_j op(" if ") i eq.not j $

that the #emph[bid]s can be sorted chronologically.

Given this chronological ordering, let's group the #emph[bid]s by creating subsequences of constant _parameters_:

//$ A_(i_1) $

//#let B1 = {B_1, ..., B_(i_1)}

//$ underbrace(B1, PP_1) $
//$ underbrace(B_1, ..., B_(i_1), PP_1) $
//$\underbrace{B_1, \ldots, B_{i_1}}_{\mathcal{P}_1}, \underbrace{B_{i_1+1}, \ldots, B_{i_2}}_{\mathcal{P}_2}, \ldots, \underbrace{B_{i_{G_N}+1}, \ldots, B_N}_{\mathcal{P}_{G_N}} $

that is, changing the _parameters_ $PP$ fixes the current order.

We are left with the task of ordering the #emph[bid]s given constant _parameters_ $PP$.

=== 2. Decimal Importance

The _importance_ $II$ can be converted into decimals as follows:

$ II arrow.r nu_x = frac(II_x, sum I) in [0;1] $

// $$\square\in\\\{\text{\bf{C\bf{HR}}}, \text{\bf{HR}}, \text{\bf{LURK}}, \text{\bf{SUBJ}}\\\}$$

// We also know that

// $$\nu_\text{\bf{LURK}} = 0$$

// $$\sum_\square\nu_\square = 1$$

// $$\implies\nu_\text{\bf{SUBJ}} = 1 - \nu_\text{\bf{C\bf{HR}}} - \nu_\text{\bf{HR}}$$

// which means that $\mathcal{I}$ can be represented as a 2-dim vector:

// $$\mathcal{I} = \begin{pmatrix} \nu_\text{\bf{C\bf{HR}}} \\ \nu_\text{\bf{HR}} \end{pmatrix}$$

// <br></br>
// ### 3. Define $\mathcal{M}$

// Given the previous max $\sum\mathcal{I}-1$ number of bids $[B_n,\ldots,B_m]$, we want to choose the next _bid_ $B_\text{next}$.

// First, we choose the next _bid_ _category_ as the _category_ that brings our realized _importance_ [closest](https://github.com/2i2i/whitepaper/blob/main/Notes.md#distance) ($\delta$) to the target _importance_ as set by the seller.

// To that end, calculate the realized _importance_ $\hat{\mathcal{I}}$ including an *assumed* next _bid_ _category_ $\text{BC}(B_\text{next})$

// $$\hat{\mathcal{I}}=\begin{pmatrix} \hat{\nu}_\text{\bf{C\bf{HR}}} \\ \hat{\nu}_\text{\bf{HR}} \end{pmatrix}$$

// $$\hat{\nu}_\square = \frac{\\\#\\\{\text{BC}(B_i)==\square\\\}_{i=n\ldots m+1}}{m-n+1}$$

// and choose $\text{BC}(B_\text{next})$ as $\underset{\text{BC}(B_\text{next})}{\text{argmin }}\delta(\mathcal{I}, \hat{\mathcal{I}})$.

// If the next _category_ should be $\text{\bf{C\bf{HR}}}$, then $B_\text{next}$ is the chronogically next $\text{\bf{C\bf{HR}}}$ _bid_ available.

// If the next _category_ should be $\text{\bf{HR}}$, then $B_\text{next}$ is the value ordered next $\text{\bf{HR}}$ _bid_ available.

// If the next _category_ should be $\text{\bf{SUBJ}}$, then $B_\text{next}$ can be chosen in the two following ways:

// 1. $B_\text{next}$ is the chronogically next $\text{\bf{SUBJ}}$ _bid_ available. However, the _seller_ can choose to decline the _bid_, using it's subjective value function.

// 1. Let the _seller_ choose one xor none from all the existing $\text{\bf{SUBJ}}$ #emph[bid]s.

// >Either case results in a [total](https://github.com/2i2i/whitepaper/blob/main/Notes.md#total-ordering), deterministic and objective ordering of all the _objective_ _bids_ and a total subjective ordering of all the _subjective_ #emph[bid]s, both interwoven according to the chosen _importance_ $\mathcal{I}$.

// A discussion of the choices is found [here](https://github.com/2i2i/whitepaper/blob/main/Notes.md#full-subj-choice-is-better).


// Note the next _category_ can never be $\text{\bf{LURK}}$, as $\nu_\text{\bf{LURK}}=0$. The _seller_ can convert $\text{\bf{LURK}}$ #emph[bid]s into $\text{\bf{C\bf{HR}}}$ or $\text{\bf{HR}}$ #emph[bid]s or vice-versa by changing the _minimum_ $\underline{M}$.

// <br></br>
// ## Worst case _rank_

// Any _bid_ can always choose to cancel, thereby *improving* the _rank_ of all #emph[bid]s behind it. Hence we only need to talk about the worst case.

// Worst case rank is deterministic if we allow it to be $\infty$, which it is for _HR_, _SUBJ_, _LURK_.

// ### _CHR_
// The above algorithm keeps the worst case _rank_ for _CHR_ #emph[bid]s [deterministic and finite]().

// This is mainly because each $\mathcal{I}$ is finite, the number of #emph[bid]s is finite, internal _CHR_ order is total and deterministic and change of _parameters_ locks all existing objective bids in a total order.




// <br></br><br></br>
// # <b>III. Infinite inclusivity</b>
// <br></br>

// ## The case

// We can assume that any possible _supply_ $\mathcal{S}$ has positive value, even if miniscule. The old world did not allow the transfer of smaller values than some threshold.

// Using a chain of _CFS_, defined below, we can transact arbitrarily small (or large) values.

// Hence, every kind and quantity of any _supply_ is supported.
// This market model is _infinitely inclusive_.

// <br></br>
// ## Smart contracts

// Smart contracts are autonomous, decentralized apps. The described market model is implemented as a smart contract for the following reasons: _infinite inclusivity_, zero credit risk, perfect [transparency](https://github.com/2i2i/whitepaper/blob/main/Notes.md#auditability-is-better), ability to use any kind of _currency_.

// <br></br>
// ## _Fungability_

// A _currency_ is called _fungible_ if it is available in varying units.

// We can define the _fungability_ $\mathbb{F}$ of a _currency_ as the ratio of it's base unit to it's minimal unit.

// E.g. 

// $$\mathbb{F}(\text{USD})=10^2$$

// $$\mathbb{F}(\text{BTC})=10^8$$

// $$\mathbb{F}(\text{NFT})=10^0=1$$

// <br></br>
// ## Constant Factor Stablecoin (_CFS_)

// A _CFS_ is a simple, permissionless smart contract that exchanges the minimal unit of a _currency_ $\text{ccy}_1$ for $\phi$ units of a new currency $\text{ccy}_2$ and vice-versa, as available.

// $\text{ccy}_2$ is created by and initially fully owned by the _CFS_. For the current intents and purposes, we can refer to $\text{ccy}_2$ as the _CFS_

// $$\text{ccy}_2 \approx \text{CFS}(\text{ccy}_1, \phi)$$

// A _CFS_ never rounds and only makes exact exchanges.

// Using a _CFS_, we have increased the fungability of [any](https://github.com/2i2i/whitepaper/blob/main/Notes.md#fungable-nfts) _currency_ $\text{ccy}$

// $$\mathbb{F}(\text{CFS}(ccy, \phi)) = \phi \cdot \mathbb{F}(ccy)$$

// <br></br>
// ## Infinitely inclusive

// Assume the value of the _supply_ $\mathcal{S}$ is $\epsilon > 0$. $\epsilon$ can be arbitrarily small.

// By chaining CFS, we can keep increasing the _fungability_ until $\epsilon$ can be represented exactly.

// $$\mathbb{F}(\text{CFS}^N(ccy, \phi)) = \phi^N \cdot \mathbb{F}(ccy)$$

// > A chain of CFS can achieve arbitrary _fungability_.



// <br></br>
// <br></br>
// # <b>IV. Conclusion</b>
// <br></br>

// ## Provably _fairest_ market

// Consider:

// - We accomodate any supply of arbitrarily small or large value.
// - We allow any currency, whether those of objective value xor subjective value.
// - We define currency as an arbitrarily fungible bundle of arbitrary energy and information.
// - We accomodate the entire region of objective value currencies possible (below, at and above the min value).
// - We create the desired (according to importance) sequence of servicing the demand.
// - We allow for infinite types of dynamics incl. traditional markets as special cases, set via simple parameters.

// All these superlatives make this market model the most open possible.

// > Assuming liquidity, this market model thus provides the fairest valuation of any supply.

// By changing the parameters, minimum $\underline{M}$ and importance $\mathcal{I}$, the seller can run a [multi-dim optimisation](https://github.com/2i2i/whitepaper/blob/main/Notes.md#multidim-optimisation) to find the type of market that maximises it's value.

// <br></br>
// ## Provably fairest economy

// An _economy_ is a set of _trade_s. The event of a _bid_ getting _serviced_ is a _trade_. If this market model provides the _fairest_ valuation and with it the _fairest_ trade, then the resulting _economy_ is _fairest_ _economy_ possible.

// Micro-economics teaches us that (specilization and) *fair* trading improves the value of all parties.

// <br></br>
// ## Maximum value $\Leftrightarrow$ Supply = _time_

// If this paper is correct in that the described market model results in the _fairest_ valuation, then it should be used for all _market_s. Especially the most valuable market:
// [_time_](https://github.com/2i2i/whitepaper/blob/main/Notes.md#live-in-the-now)

// - Everyone has _time_
// - Everyone knows that _time_ is most valuable.

// When _supply_=_time_, all currencies are per $\Delta T$. Current technology already allows $\Delta T \le 1 \text{ sec}$.

= Notes

//#locate(loc => {
//  hi
//})

Call me Ishmael. Some years ago --- never mind how long precisely ---
having little or no money in my purse, and nothing particular to
interest me on shore, I thought I would sail about a little and see
the watery part of the world. It is a way I have of driving off the
spleen, and regulating the circulation.  Whenever I find myself
growing grim about the mouth; whenever it is a damp, drizzly November
in my soul; whenever I find myself involuntarily pausing before coffin
warehouses, and bringing up the rear of every funeral I meet; and
especially whenever my hypos get such an upper hand of me, that it
requires a strong moral principle to prevent me from deliberately
stepping into the street, and methodically knocking people's hats off
--- then, I account it high time to get to sea as soon as I can. This
is my substitute for pistol and ball. With a philosophical flourish
Cato throws himself upon his sword; I quietly take to the ship. There
is nothing surprising in this. If they but knew it, almost all men in
their degree, some time or other, cherish very nearly the same
feelings towards the ocean with me. @netwok2020

There now is your insular city of the Manhattoes, belted round by
wharves as Indian isles by coral reefs - commerce surrounds it with
her surf. Right and left, the streets take you waterward. Its extreme
down-town is the battery, where that noble mole is washed by waves,
and cooled by breezes, which a few hours previous were out of sight of
land. Look at the crowds of water-gazers there.

Anyone caught using formulas such as $sqrt(x+y)=sqrt(x)+sqrt(y)$
or $1/(x+y) = 1/x + 1/y$ will fail.

The binomial theorem is
$ (x+y)^n=sum_(k=0)^n binom(n, k) x^k y^(n-k). $

A favorite sum of most mathematicians is
$ sum_(n=1)^oo 1/n^2 = pi^2 / 6. $

Likewise a popular integral is
$ integral_(-oo)^oo e^(-x^2) dif x = sqrt(pi) $

#theorem[
  The square of any real number is non-negative.
]

#proof[
  Any real number $x$ satisfies $x > 0$, $x = 0$, or $x < 0$. If $x = 0$,
  then $x^2 = 0 >= 0$. If $x > 0$ then as a positive time a positive is
  positive we have $x^2 = x x > 0$. If $x < 0$ then $−x > 0$ and so by
  what we have just done $x^2 = (−x)^2 > 0$. So in all cases $x^2 ≥ 0$.
]

= Introduction
This is a new section.

== Things that need to be done
Prove theorems.

= Background
#lorem(40)
