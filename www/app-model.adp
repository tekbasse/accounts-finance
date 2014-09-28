<master>
    <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h1>@title@</h1>
<if @menu_html@ not nil>
@menu_html;noquote@
</if>

<if @user_message_html@ not nil>
<ul>
@user_message_html;noquote@
</ul>
</if>


<if @form_html@ not nil>
@form_html;noquote@
</if>

<if @initial_conditions_html@ not nil>
<div style="width: 60%; float: right;">
<table border="0" cellspacing="0" cellpadding="5">
<tr>
<td valign="top"><tt>commissions_eq</tt></td>
<td valign="top">1 = trangular equation distribution, largest first. 2 = harmonic equation, largest first. 3 = geometric tuned equation of the trianglular distribution biased to sales revenue for each affiliate.
 </td>
</tr><tr>
<td valign="top"><tt>growth_curve_eq</tt></td>
<td valign="top">0 = ignore. 1 = Logistic curve, 2 = Positive Sign curve. 
These equations are set to take intervals anywhere between 0 to 12 inclusive. Fractional decimals are fine. 
For the Logistic curve, the target_revenue is reached at about 12. 
For the Positive Sign curve, target_revenue is reached at interval 6 and decreases to 0% at 12 --useful to test extreme negative growth scenarios.
 </td>
</tr><tr>
<td valign="top"><tt>interpolate_last_band_p</tt></td>
<td valign="top">Set this to 1 to have the largest sale tier iterpolated. (default = 0)
This is useful for modeling infrequent, large sales volumes with varying, significant quantities. </td>
</tr><tr>
<td valign="top"><tt>interval_count</tt></td>
<td valign="top">Number of intervals iterated.</td>
</tr><tr>
<td valign="top"><tt>interval_size</tt></td>
<td valign="top">added to period_start for each interval </td>
</tr><tr>
<td valign="top"><tt>interval_start</tt></td>
<td valign="top">The value for the first period's interval  </td>
</tr><tr>
<td valign="top"><tt>pct_pooled</tt></td>
<td valign="top">the commission from total revenue (as a decimal percentage)</td>
</tr><tr>
<td valign="top"><tt>period_unit</tt></td>
<td valign="top">The unit that represents each period.</td>
</tr><tr>
<td valign="top"><tt>revenue_target</tt></td>
<td valign="top">the target amount of sales. The total revenue for each period is one sale above target.</td>
</tr><tr>
<td valign="top"><tt>sale_max</tt></td>
<td valign="top">the maximum value of a single sale.</td>
</tr><tr>
<td valign="top"><tt>sales_curve_name</tt></td>
<td valign="top">Name of sales curve to use. Name must be unique</td>
</tr><tr>
<td valign="top"><tt>sales_curve_tid</tt></td>
<td valign="top">Table ID of sales_curve to use.</td>
</tr><tr>
<td valign="top"><tt>sample_rate</tt></td>
<td valign="top">Percentage of rows per period to be sampled. (The percent is represented as decimal: 100% = 1).  </td>
</tr></table>
</div>
@initial_conditions_html;noquote@
</if>

<if @sales_curve_html@ not nil>
@sales_curve_html;noquote@
</if>

<if @compute_message_html@ not nil>
<ul>
@compute_message_html;noquote@
</ul>
</if>

<if @computation_report_html@ not nil>
@computation_report_html;noquote@
</if>

<if @table_stats_html@ not nil>
@table_stats_html;noquote@
</if>

<!--
<p>The real problem with MLM is not MLM itself, but some [many] of the people it attracts. [1]
</p>
<p>The salient characteristics of MLM make it attractive to people who[1]:
<ul><li>
    have not done well in their business or profession and have little money saved up to invest
</li><li>
    have no previous experience owning or running a business
</li><li>
    have no previous experience in sales
</li><li>
    have little or no experience developing business relationships other than that of employer/employee/co-worker
</li><li>
    are not satisfied with their current level of income
</li><li>
    have unrealistic expectations of the amount of work involved compared to the revenue realized
</li></ul>


<p>Benefits of this affiliate program (vs. MLM)</p>
<ul><li>
Can be applied retroactively to start a program with an existing sales network
</li><li>
No network fragmentation points -- a collaborative network instead of competing network prone to in-fighting
</li><li>
Fewer network management data points -- lower network management overhead
</li><li>
Network adjusts well to market variations
</li><li>
Network is resilient to abusive practices
</li><li>
Network doesn't fit traditional MLM characteristics, thereby meets fewer legal restrictions
</li><li>
No barriers to building network using any communication channel, including social networking
</li></ul>
<p>
Before we can model an affiliate program, we need to make a
reasonable model that resembles sales patterns.
</p>

<h3>Affiliate program calculations</h3>
<p>Sales goal: $??sales_amount_target??</p>
<p>Total amount sold: ??sales_bal??</p>
<p>Initial pool to be divided up: $??commission_pot?? ie ??pct_pooled??% of sales.</p>
<p>Number of "quantum" parts: ??shares_tot??</p>
<p>Sum of all bonus rewards: $??bonuses_tot??</p>
<p>Each "quantum" part is valued at $??share_value??</p>
<p>Amount of sales used for affiliate program in this run: ??pct_of_sales??</p>
??apt_html;noquote??


<p>This affiliate program issues a bonus.
</p>

<p>Here's how the affiliate program works:</p>
<p>Affiliates qualify for a reward for participating early. 
You can see the progression by looking at this example 
scenario.</p>


<p>If an affiliate makes multiple purchases, 
the earliest sale counts for their position in the progression. 
The total sale amount is the sum of all of an affiliates' purchases within a period.</p>

<p>Refreshing the page creates a new scenario with different sales chosen randomly.</p>



<h3>comments</h3>
<p>Most social network-marketing involves rewarding only the referers and their referers. MIT won a DARPA challenge using this traditional approach[2]. The model above rewards only based on sequence and the amount of sales. This is a cooperative approach with no competition between affiliates, only market competition.</p>
<p>
discussion: Google Adsense program successfully advertises without allowing affilaites to discuss their earnings.
</p>

<p>1. The Real Problem with Network Marketing and Multi-Level Marketing (MLM) by Scott Allen, former About.com Guide <a href="http://entrepreneurs.about.com/cs/multilevelmktg/a/problemwithmlm.htm">http://entrepreneurs.about.com/cs/multilevelmktg/a/problemwithmlm.htm</a>
</p>
<p>2. example of MIT winning a social-networking mobilization challenge by DARPA <a href="http://web.mit.edu/press/2009/darpa-challenge-1210.html">http://web.mit.edu/press/2009/darpa-challenge-1210.html</a>
</p>
<pre>
Notes. See also:
http://entrepreneurs.about.com/lr/network_marketing/353883/1/

http://entrepreneurs.about.com/od/networkmarketingmlm/a/10tipstopicknwm.htm

http://womeninbusiness.about.com/od/marketingglossary/a/what-assisted-marketing-plans.htm

http://womeninbusiness.about.com/od/marketingglossary/a/definition-multi-level-marketing.htm

http://womeninbusiness.about.com/lr/networking_marketing/738394/2/

See also Income levels in: http://en.wikipedia.org/wiki/Multi-level_marketing
and http://www.mlmlegal.com for local expert with important questions on website.

Methods of caclulating shares:
Triangular number
(a variation of the lazy caterer's sequence http://en.wikipedia.org/wiki/Lazy_caterer%27s_sequence)
The "share the loot" scenario, split the commission pot evenly between people.

Sell own supply. Affiliates can buy supply at same price as retailers. The traditional entrepreneur/sales agent scenario.
Affiliates must maintain a quota of 1 person's serving per day --or lose position.
"Quota history expires at 365 days previous." Keeps positions actively buying/promoting with fresh inventory.
commission pool includes sales to wholesalers.

</pre>
-->
