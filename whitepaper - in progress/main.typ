#import "template.typ": *
#show: ams-article.with(
  title: "FairMarket ~ the provably fairest and most inclusive market model",
  authors: (
    (
      name: "1m1",
      email: "email@1m1.io",
    ),
  ),
  abstract: "This paper describes a novel, multi-dimensional, infinitely inclusive market model. The described model yields infinite types of new market dynamics and traditional markets as special cases, based on very few parameters. As the market allows any supply of arbitrarily small or large value to be traded in any currency, incl. subjective value currencies, any resulting liquid market must then find the fairest value of the supply.",
  //bibliography-file: "refs.bib",
)
#show link: underline
#set heading(level: 1, numbering: "I")
#set heading(level: 2, numbering: "I.1")

= Definitions

== Market
\ \
Assume we have a _seller_ with a finite _supply_ $SS$ and there exists a _demand_ $DD$ consisting of #emph[bid]s.
\ \ 
A _market_ $MM$ is a function that determines the *next* _bid_ to be #link(<all-trade-is-sequential>)[serviced]. Formally,

$ MM(SS, DD) = B $

where $B in DD$ is a _bid_.
\ \ 

More generally, we add a parameter to the _market_ $MM$ to output the _bid_ *next after* some given _bid_ $B$.

$ MM(SS, DD, B) = B#sub[next] $

$ B, B#sub[next] in DD union nothing $
\ 
$nothing$ represents an end, as follows. Simplifying $MM(SS, DD, B)$ to $MM(B)$,

$ MM(nothing) = B#sub[first] $
$ MM(B#sub[last]) = nothing $
\ 
This then allows for an ordering of the #emph[bid]s

$ DD = [B#sub[1], ..., B#sub[N]] = [MM^1(nothing), MM^2(nothing), ..., MM^N(nothing)] = [MM#super[rank] (nothing)]_(op("rank")=1)^N $
\ 
In this paper, we will define a partial ordering and a total ordering that is #link(<fairest>)[_fairest_], most #link(<most-inclusive>)[_inclusive_] and accomodates #link(<all-markets>)[all] types of #emph[market]s, as well as innovating new types of #emph[market]s with a generic framework.
\ \ 
== Parameters
\ \
The _seller_ sets the following _parameters_ $PP$:

$ PP = (underline(M), II) $

$ underline(M) gt.eq 0 op(" minimum value of the supply") $

$ II = op("importance") $
\ 
The _importance_ $II$ will be explained later. It is a setting of the _seller_ defining the importance of the different categories of #emph[bid]s.
\ \
== Bid
\ \
Each _bid_ $B$ looks as follows:

$ B = (T, A, PP) $

$ T = op("time of creation") $

$ A = (q, op("ccy"), op("FX")) op(" is the amount of the bid") $

$ PP = op(" the sellers parameters at time ") T $
\
The _amount_ $A$ contains a quantity $q$, a _currency_ $op("ccy")$ and an exchange rate to a _base currency_ $op("FX")$, all fixed at time $T$.
\ \ 

== Currency and FX
\ \ 
#let FX = "FX"
#let ccy = "ccy"
#let obj = "obj"
#let subj = "subj"
#let base = "base"

Let $CC$ be the universe of all existing #link(<currency>)[currencies]. Then

$ CC = CC_obj union.dot CC_subj $

that is, any _currency_ either has #link(<objective-vs-subjective-value>)[objective value xor subjective value].
\ \
We choose some

$ ccy_base in CC_obj $

as the _base currency_ and we define
\ \
$ FX(ccy) = FX(ccy, T) = FX(ccy, ccy_base, T) $
\
as the _fair_ exchange rate between $ccy$ and $ccy_base$, i.e.
\ \
$ 1 [ccy] = FX(ccy) [ccy_base] $

and

$ FX(ccy) = nothing op(" if") ccy in CC_subj $
\ \

Before we categorize the #emph[bid]s, let's simplify them. First, we call a _bid_ $B$ _objective_

$ B op(" is objective") arrow.l.r.double ccy in CC_obj $

if it is of an objective value currency.
\ \

The _amount_ $A$ of each _objective_ _bid_ can be transformed into the chosen _base currency_, as follows:

$ B(T, A = (q, ccy, FX), PP) arrow.r B_base(T, A = (FX dot.op q , ccy_base, FX ident.strict 1), PP) $
\ \ 
*This means, without loss of generality, we can #link(<assuming>)[assume] all _objective bids_ to be denominated in the _base currency_.*
\ \ 
== _Bid_ Categories
\ \ 
#let chrony = "chrony"
#let CHR = "CHR"
#let highroller = "highroller"
#let HR = "HR"
#let lurker = "lurker"
#let LURK = "LURK"
#let subjective = "subjective"
#let SUBJ = "SUBJ"
#let BC = "BC"

#link(<assuming>)[Assuming] that the _min_ value $underline(M)$ is also in the _base currency_, we #link(<practical-chrony>)[define] the following 4 _bid_ categories:

$ chrony (bold(CHR)) arrow.l.r.double B op(" is objective and ") q = underline(M) $
$ highroller (bold(HR)) arrow.l.r.double B op(" is objective and ") q > underline(M) $
$ lurker (bold(LURK)) arrow.l.r.double B op(" is objective and ") q < underline(M) $
$ subjective (bold(SUBJ)) arrow.l.r.double B op(" is subjective") $
\ \
We can denote a _bid_ $B$'s _category_ as $BC(B)$.
\ \
== _Importance_
\ \
The _seller_ defines the _importance_ per _bid_ _category_

$ II = (II_CHR, II_HR, II_LURK, II_SUBJ) $

where each _importace_ is a natural number

$ II_x in NN_(gt.eq 0), x in {CHR, HR, LURK, SUBJ} $

the market is activated
$ 0 < sum_x II_x =: sum II $

and the #link(<why-lurkers>)[_lurkers_] never get serviced

$ II_LURK = 0 $
\ \

Amongst every subsequence of the ordered #emph[bid]s $[B_n, ..., B_m]$ of length $sum II$, on average, we get $II_x$ many of _bid_ _category_ $x$.

E.g. if

$ II = (II_CHR = 2, II_HR = 3, II_LURK = 0, II_SUBJ = 1) $

then, on average, any subsequence of 6 #emph[bid]s _serviced_ should contain 2 _chrony_, 3 _highroller_ #emph[bid]s and 1 _subjective_ _bid_.
\ \

= The market $MM$
\ \
== Characteristics
\ \
We want to create a _market_ function such that:

- _importance_ is respected

- order of _objective_ #emph[bid]s is objectively #link(<deterministic>)[deterministic]

- internal category order is maintained

- worst case _rank_ for _chrony_ _bids_ is #link(<chrony-only-worst-case-finite>)[finite]

- the _seller_ can use it's own subjective value function to value #emph[subjective bid]s
\ \
== Internal category order
\ \
_Chrony_ #emph[bid]s are _time_ ordered, _highroller_ _bids_ are _value_ ordered, _subjective_ #emph[bid]s are ordered by each _seller_ *subjectively* and _lurker_ #emph[bid]s live in the #link(<projective-infinity>)[projective infinity], never serviced.
\ \
== Traditional #emph[market]s as special cases
\ \
- Fixed price

$ underline(M) = op("fixed price") $

$ II = (II_CHR = 1, II_HR = 0, II_LURK = 0, II_SUBJ = 0) $

- Auction

$ underline(M) = op("min price") $

$ II = (II_CHR = 0, II_HR = 1, II_LURK = 0, II_SUBJ = 0) $

- Barter

$ II = (II_CHR = 0, II_HR = 0, II_LURK = 0, II_SUBJ = 1) $

*All other cases are mixed, innovative #emph[market]s and can yield differing dynamics.*
\ \

== The algorithm

1. Sort the #emph[bid]s

We can almost surely assume

$ T_i eq.not T_j op(" if ") i eq.not j $

that the #emph[bid]s can be sorted chronologically.

Given this chronological ordering, let's group the #emph[bid]s by creating subsequences of constant _parameters_:

$ underbrace(B_1 + ... + B_i_1, PP_1), underbrace(B_(i_1+1) + ... + B_i_2, PP_2), ..., underbrace(B_(i_G_N+1) + ... + B_N, PP_G_N) $

that is, changing the _parameters_ $PP$ fixes the current order.
\ \

We are left with the task of ordering the #emph[bid]s given constant _parameters_ $PP$.
\ \ 
2. Decimal Importance

The _importance_ $II$ can be converted into decimals as follows:

$ II arrow.r nu_x = frac(II_x, sum I) in [0;1] $

$ x in {CHR, HR, LURK, SUBJ} $
\ \ 
We also know that

$ nu_LURK = 0 $

$ sum_x nu_x = 1 $

$ arrow.r.double nu_SUBJ = 1 - nu_CHR - nu_HR $
\ \ 
which means that $II$ can be represented as a 2-dim vector:

$ II = vec(nu_CHR, nu_HR) $

\ \
3. Define $MM$

Given the previous max $sum II - 1$ number of #emph[bid]s $[B_n, ... ,B_m]$, we want to choose the *next* #emph[bid] $B#sub[next]$.
\ \ 
First, we choose the next _bid_ _category_ as the _category_ that brings our realized _importance_ #link(<distance>)[closest] ($delta$) to the target _importance_ as set by the seller.
\ \ 
To that end, calculate the realized _importance_ $hat(II)$ including an *assumed* next _bid_ _category_ $BC(B#sub[next])$

$ hat(II) = vec(hat(nu)_CHR, hat(nu)_HR) $


$ hat(nu)_x = frac(\#{BC(B_i) == x}#sub[i=n...m+1], m - n + 1) $

and choose $BC(B#sub[next])$ as $limits("argmin")_(BC(B#sub[next])) delta(II, hat(II))$.
\ \ 

If the next _category_ should be $CHR$, then $B#sub[next]$ is the chronogically next $CHR$ _bid_ available.

If the next _category_ should be $HR$, then $B#sub[next]$ is the value ordered next $HR$ _bid_ available.

If the next _category_ should be $SUBJ$, then $B#sub[next]$ can be chosen in the two following ways:

a. $B#sub[next]$ is the chronogically next $SUBJ$ _bid_ available. However, the _seller_ can choose to decline the _bid_, using it's subjective value function.

b. Let the _seller_ choose one xor none from all the existing $SUBJ$ #emph[bid]s.
\ \ 

*Either case results in a #link(<total-ordering>)[total], deterministic and objective ordering of all the _objective_ _bids_ and a total subjective ordering of all the _subjective_ #emph[bid]s, both interwoven according to the chosen _importance_ $II$.*

A discussion of the choices is found #link(<full-subj-choice-is-better>)[here].
\ \ 

Note the next _category_ can never be $LURK$, as $nu_LURK=0$. The _seller_ can convert $LURK$ #emph[bid]s into $CHR$ or $HR$ #emph[bid]s or vice-versa by changing the _minimum_ $underline(M)$.

\ \
== Worst case _rank_
\ \ 
Any _bid_ can always choose to cancel, thereby *improving* the _rank_ of all #emph[bid]s behind it. Hence we only need to talk 
about the worst case.

Worst case rank is deterministic if we allow it to be $infinity$, which it is for _HR_, _SUBJ_, _LURK_.

_CHR_
The above algorithm keeps the worst case _rank_ for _CHR_ #emph[bid]s [deterministic and finite]().

This is mainly because each $II$ is finite, the number of #emph[bid]s is finite, internal _CHR_ order is total and deterministic and change of _parameters_ locks all existing objective bids in a total order.



\ \ \ \
= *Infinite inclusivity*
\ \

== The case

We can assume that any possible _supply_ $SS$ has positive value, even if miniscule. The old world did not allow the transfer of smaller values than some threshold.

Using a chain of _CFS_, defined below, we can transact arbitrarily small (or large) values.

Hence, every kind and quantity of any _supply_ is supported.
This market model is _infinitely inclusive_.

\ \
== Smart contracts

Smart contracts are autonomous, decentralized apps. The described market model is implemented as a smart contract for the following reasons: _infinite inclusivity_, zero credit risk, perfect #link(<auditability-is-better>)[transparency], ability to use any kind of _currency_.

\ \
== _Fungability_

A _currency_ is called _fungible_ if it is available in varying units.

We can define the _fungability_ $FF$ of a _currency_ as the ratio of it's base unit to it's minimal unit.

E.g. 

$ FF("USD") = 10^2 $
$ FF("BTC") = 10^8 $
$ FF("NFT") = 10^0 = 1 $

\ \
== Constant Factor Stablecoin (_CFS_)

A _CFS_ is a simple, permissionless smart contract that exchanges the minimal unit of a _currency_ $ccy_1$ for $phi$ units of a new currency $ccy_2$ and vice-versa, as available.

$ccy_2$ is created by and initially fully owned by the _CFS_. For the current intents and purposes, we can refer to $ccy_2$ as the _CFS_

$ ccy_2 approx "CFS"(ccy_1, phi) $

A _CFS_ never rounds and only makes exact exchanges.

Using a _CFS_, we have increased the fungability of #link(<fungable-nfts>)[any] _currency_ $ccy$

$ FF("CFS"(ccy, phi)) = phi dot.op FF(ccy) $

\ \
== Infinitely inclusive

Assume the value of the _supply_ $SS$ is $epsilon > 0$. $epsilon$ can be arbitrarily small.
\ \ 
By chaining CFS, we can keep increasing the _fungability_ until $epsilon$ can be represented exactly.

$ FF("CFS"^N(ccy, phi)) = phi^N dot.op FF(ccy) $

*A chain of CFS can achieve arbitrary _fungability_.*



\ \
\ \
= *IV. Conclusion*
\ \

== Provably _fairest_ market

Consider:

- We accomodate any supply of arbitrarily small or large value.
- We allow any currency, whether those of objective value xor subjective value.
- We define currency as an arbitrarily fungible bundle of arbitrary energy and information.
- We accomodate the entire region of objective value currencies possible (below, at and above the min value).
- We create the desired (according to importance) sequence of servicing the demand.
- We allow for infinite types of dynamics incl. traditional markets as special cases, set via simple parameters.

All these superlatives make this market model the most open possible.

*Assuming liquidity, this market model thus provides the fairest valuation of any supply.*

 By changing the parameters, minimum $underline(M)$ and importance $II$, the seller can run a #link(<multidim-optimisation>)[multi-dim optimisation] to find the type of market that maximises it's value.

\ \
== Provably fairest economy

An _economy_ is a set of #emph[trade]s. The event of a _bid_ getting _serviced_ is a _trade_. If this market model provides the _fairest_ valuation and with it the _fairest_ trade, then the resulting _economy_ is _fairest_ _economy_ possible.

Micro-economics teaches us that (specilization and) *fair* trading improves the value of all parties.

\ \
== Maximum value $arrow.l.r.double$ Supply = _time_

If this paper is correct in that the described market model results in the _fairest_ valuation, then it should be used for all #emph[market]s. Especially the most valuable market: #link(<live-in-the-now>)[_time_]

- Everyone has _time_
- Everyone knows that _time_ is most valuable.

When _supply_=_time_, all currencies are per $Delta T$. Current technology already allows $Delta T lt.eq 1 "sec"}$.

= *Notes*

\ \
== most inclusive <most-inclusive>
Considering only supplies of positive value, since we can support arbitrarily small or large values, in any type currency, we are infinitely inclusive. Being infinitely inclusive also makes it most inclusive.

\ \
== fairest <fairest>
The fairest value is achieved in the most open market possible based on the assumption that adding an intelligence to a group of intelligences increases the accuracy of the joined valuation of anything. It is valuation based on maximal information.

\ \
== fungable NFTs <fungable-nfts>
Even an NFT could in this manner be broken into smaller pieces. Having art with higher fungability increases the size of the demand, however it also seems to decrease the perceived value by some.

\ \
== full subj choice is better <full-subj-choice-is-better>
Since the seller is using it's own subjective value function, there can be no apriori internal ordering. And since there is no point in cancelling bids by the seller, as a bid can simply reappear (unless the bidder is blocked), there is no need for any internal ordering. If the next bid is $SUBJ$ then the seller can choose any or none of the $SUBJ$ bids.

\ \
== distance <distance>
For $delta$, we can choose any 2-dim distance measure, e.g. the Euclidean metric.

\ \
== practical chrony <practical-chrony>
For practical reasons, such as real time FX changes, it can make sense to define the categories with a precision $epsilon>0$, and the relative distance $delta=ln(q/underline(M))$ as follows

$ "chrony" (CHR) arrow.l.r.double B " is objective and " |delta| lt.eq epsilon $

$ "highroller" (HR) arrow.l.r.double B " is objective and " delta > epsilon $

$ "lurker" (LURK) arrow.l.r.double B " is objective and " delta < -epsilon $

\ \
== why lurkers <why-lurkers>
Lurkers complete the picture of the demand. They allow the seller to realise the optimal minimum price. Traditional markets leave sellers blind to this entire bottom part of the demand.

\ \
== assuming <assuming>
These are not real 'assumptions'. These prerequisites that we are asking for are trivial and hence we are "assuming" them to be true already. Real 'assumptions' can be wrong.

\ \
== energy and info <energy-and-info>
Energy and information as defined by the Sciences, as two fundamental elements of nature.

\ \
== min value <min-value>
Every seller has the right to define it's own minimum value for its supply.

\ \
== all markets <all-markets>
I think this statement can be made formally thanks to us defining _currency_ as generally as possible.

\ \
== all trade is sequential <all-trade-is-sequential>
Serviced is used as meaning "traded".

Any finite supply requires ordering of demand. All selling of any supply is approximately sequential and most selling is sequential. Even selling digital copies of a product that seems unlimited, is in fact limited due to network bandwidth being limited and servers usually order demand on a "first-come, first-serve" basis. When supply is very large vs demand, then modeling a simultaneous trading sequentially, is not any loss at all, as the sequence can simply move very fast, giving the illution of simultaneouity.

\ \
== chrony only worst case finite <chrony-only-worst-case-finite>
This is a service guarantee for those bidding the minimum (chrony). A highroller is basically participating in an auction for a sooner service, which is only sooner iff $II_CHR < II_HR$. An subjective bid might never be serviced, as it depends on the seller's subjective value function. A lurker is by definition never serviced.

\ \
== deterministic and finite <deterministic-and-finite>
should be written up formally
see fairmarket.js in FairInbox for formalism
since non availability of a category is what triggers the only change possible in ordering, and this kind of event improves every bids ordering, descreasing the wait time. thus max wait time is deterministic. we have the formula. see dart code. 

\ \
== auditability is better <auditability-is-better>
Even better than transparency is privacy with auditibility. This allows entities to maintain private information whilst satisfying society that everything is legal.

\ \
== multidim optimisation <multidim-optimisation>
Based on my own intensive research on highly noisy and highly dimensional optimisation, I have found a multi-start Nelder-Maed to provide the best result. Solutions that have many simulations ending in them are much more likely to contain true information, rather than noise, i.e. being less outlier prone.

\ \
== objective vs subjective value <objective-vs-subjective-value>
Any currency can be said to have objective value if there exists a liquid market to exchange at least the base unit of this currency into another objective value currency. We assume that a community can agree on at least one currency that is declared objective.

Every other currency is called subjective. 

\ \
== currency <currency>
We define a currency as any bundle of energy and information that can be transmitted from one entity to another, incl. bundles containing no energy (only information) xor only energy (no information).

This provides the most generic definition possible.

\ \
== projective infinity <projective-infinity>
Not formalized in this whitepaper.

\ \
== total ordering <total-ordering>
Objective bids already have deterministic ordering. If subjective bids are presented in time order, we get a total ordering using the sellers subjective value function. The total ordering is known only to the seller.

\ \
== deterministic <deterministic>
means that the outputs will not change if the inputs do not change

\ \
== live in the now <live-in-the-now>
One could even replace appointments with such a market for ones **time**. Whenever you choose to interact with a person, instead of consulting an appointment schedule, consult the market. Importance and urgency are all expressed via the energy and information contained in every bid.

Btw, time can e.g. easily be supplied via live media streams.

\ \
== acknowledgement <acknowledgement>
The information found in this white paper was created by [1m1](https://1m1.io) with the help of Solli Kim. Thank you Solli for sharing your mind.