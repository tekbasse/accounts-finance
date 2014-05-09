<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>

<h2>Finance Package @title@</h2>

<p>Finance Package provides some tools for forecasting and reporting</p>

<p>The lastest version of the code is available at the development site:
 <a href="http://github.com/tekbasse/accounts-finance">http://github.com/tekbasse/accounts-finance</a></p>

<h3>introduction</h3>

<p>
Finance package provides a library of procedures for use with financial accounting
and related topics, including long-term debt, fixed assets, and forecasting.
It allows tcl procedures to be used in a web-based publishing environment.
It is not tied to vertical web applications, such as OpenACS ecommerce package.
</p>

<h3>license</h3>
<pre>
Copyright (c) 2014 Benjamin Brink
po box 20, Marylhurst, OR 97036-0020 usa
email: kappa@dekka.com

Finance Package is open source and published under the GNU General Public License, 
consistent with the OpenACS system license: http://www.gnu.org/licenses/gpl.html
A local copy is available at accounts-finance/www/doc/<a href="LICENSE.html">LICENSE.html</a>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
</pre>

<h3>contents</h3>
<ul><li>
<a href="LICENSE.html">GPL 3+ License</a>
</li><li>
<a href="pretti-specs">PRETTI Specifications</a>
</li><li>
<a href="pretti">PRETTI Table definitions</a>
</li><li>
<a href="pretti-example-1">PRETTI Example 1</a> Using example from PERT Wikipedia entry retrieved from <a href="http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique">http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique</a> on 8 May 2014.
</li></ul>

<h3>
features
</h3>
<p>Project Reporting Evaluation and Track Task Interpretation (PRETTI) is an effective way to communicate complex ideas of timing, sequence and dependencies to project stakeholders. Each report consists of a table of fast-tracked paths highlighting the critical path (CP) as well as paths and activities that risk merging or otherwise affecting the CP. PRETTI avoids processing intensity of Monte Carlo analysis by calculating only the points requested along a distribution curve, such as the extremes and median. PRETTI provides a painless way to create a probability distribution curve for each activity based on historical records and subsequently produce a project performance distribution curve for time and value. The complexity of GERT decision paths are deferred to the activity level and probability distributions.
</p>
<p>
To be listed. 
</p><p>
See account-finance's procedure library via /api-doc/ on
a site running OpenACS with account-finance installed.
</p>
<p>
Example apps on how to use the code are in the accounts-finance/www/* directory. Missing qss_* resources indicate a dependence on the spreadsheet package. Missing qf_* resources indicate a dependence on q-forms.
</p>
<pre>
Development Notes:

will be porting in sql-ledger RP.pm and rp.pl
</pre>
