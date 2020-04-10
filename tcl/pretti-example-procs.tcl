ad_library {

    PRETTI example data used for Project Reporting Evaluation and Track Task Interpretation
    @creation-date 8 May 2014
    @cvs-id $Id:
    @Copyright (c) 2014 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/accounts-finance
    @address: po box 193, Marylhurst, OR 97036-0193 usa
    @email: kappa@dekka.com
    
    PRETTI examples and test data generator procs.

}

namespace eval acc_fin {}

ad_proc -private acc_fin::example_table {
    {table_ref ""}
} {
    Returns a list of 3 items. index 0 is table title; index 1 is table description, index 2 is table in data entry format, commas between columns, spaces between multiple items in same row and column;  
} {
    set ret_list ""
    switch -exact $table_ref {
        p10a {
            # goes with p20a
            set ret_list [list [list name value] [list activity_table_name "PRETTI Example 1"] [list time_est_short 5 ] [list time_est_median 8] [list time_est_long 12] [list time_probability_point 0.5]]
        }
        p10b {
            # goes with p20b
            set ret_list [list [list name value] [list activity_table_name "WikipediaPERTchart"]]
        }
        p10c {
            # goes with p20c
            set ret_list [list [list name value] [list activity_table_name "Fedora Release Life Cycle"]]
        }
        p10d {
            # goes with p20d
            set ret_list [list [list name value] [list activity_table_name "Fedora 20 Doc Workflow"]] }
        p10e {
            # goes with p20e
            set ret_list [list [list name value] [list activity_table_name "Fedora 20 network analysis from Project Schedule (draft)"]] }
        p10f {
            # goes with p20f
            set ret_list [list [list name value] [list activity_table_name "Example 6"]] }
        p20a {
            set ret_list [list "Wikipedia PERT" "This is an example from PERT entry of Wikipedia. See entry for details: http://en.wikipedia.org/wiki/Program_Evaluation_and_Review_Technique" "activity_ref,time_est_short,time_est_median,time_est_long,time_ext,dependent_tasks
A,2,4,6,4.0,
B,3,5,9,5.33,
C,4,5,7,5.17,A
D,4,6,10,6.33,A
E,4,5,7,5.17,B C
F,3,4,8,4.5,D
G,3,5,8,5.17,E" ]
        }
        p20b {
            set ret_list [list "Wikipedia PERT chart" "This is an example rendered from a chart image in the PERT entry of Wikipedia. See image for details: http://en.wikipedia.org/wiki/File:Pert_chart_colored.svg" "activity_ref,time_est_median,dependent_tasks,color
10,0,,grey
E,3,30,blue
A,3,10,green
B,4,10,green
20,0,B,grey
30,0,A,grey
D,1,30,blue
40,0,D,grey
F,3,40,brown
C,3,20,brown
50,0,F E C,grey
"] }
        p20c {
            set ret_list [list "Fedora Release Life Cycle tasks" "This is an example rendered from a Release Life Cycle page in the open source Fedora Project's wiki retrieved from https://fedoraproject.org/wiki/Fedora_Release_Life_Cycle on 26 September 2014" "activity_ref,dependent_tasks,time_est_median,description
planning_development,,90,Planning and Development
development,planning_development,90,Development
branch_alpha,development,14,Branch and build Alpha base
bodhi_cycling,branch_alpha,72,Bodhi maintenance release cycling \(494d overall)
translations,branch_alpha,72,Translations accepted this release \(279d overall)
alpha_testing,branch_alpha,23,Alpha testing cycle
alpha_cycles,alpha_testing,14,Alpha release candidate cycles
alpha_release,alpha_cycles,7,Alpha release
beta_testing,alpha_release,7,Beta testing cycle
beta_cycles,beta_testing,14,Beta release candidate cycles
beta_release,beta_cycles,7,Beta release
final_cycles,beta_release,14,Final release candidate cycles
final_release,final_cycles,5,GA \(Final) release"] }
        p20d {
            set ret_list [list "Fedora Doc Workflow" "This is an example rendered from a Documentation Workflow page in the open source Fedora Project's wiki retrieved from https://fedoraproject.org/wiki/Docs_Project_workflow on 26 September 2014" "activity_ref,dependent_tasks,time_est_median
collect_input,,
write_wiki,collect_input,
wiki,collect_input write_wiki,
review_wiki,wiki,
write_xml,wiki collect_input,
git,write_xml,
review_xml,git,
publish,git,
package_docs,git,
push_to_fedora,package_docs,"] }
        p20e {
            set ret_list [list "Fedora 20 Project task detail chart (draft)" "This draft example is an incomplete, third attempt at manually converting a task schedule from an example in the open source TaskJuggler Project examples at http://www.taskjuggler.org/examples.html Dependencies are not clearly, consistently defined in the schedule. Attempting a network analysis using the schedule makes this self evident.  Example file retrieved from http://www.taskjuggler.org/tj3/examples/Fedora-20/f-20.tjp on 2014-09-22." "name,activity_ref,description,dependent_tasks,time_est_median,flags
1,first_day,First Day of Development,,,hidden
2,PlanningPhase_start,Planning Phase start,,,key pm roadmap
x2,PlanningPhase_end,Planning Phase end,,,key pm roadmap
3,start_features_cal,Start/Accept Feature Submission,PlanningPhase_start,25,key pm roadmap
4,rawhide_spins,Prep/Start Nightly Spins Compose Based on Rawhide,PlanningPhase_start,5,spins
5,file_ticket,File ticket with RHT Eng-ops for Fedora 17 EOL bugzilla closure 10days after last release,PlanningPhase_start,10,pm
6,fedora17_eol,RHT Eng-Ops Fedora 17 EOL auto closure 4wks after last release,PlanningPhase_start,20,pm key
7,clean_market_wiki,Cleanup Marketing wiki from previous releases,start_features_cal,5,marketing
8,cycle_market_wiki,Cycle Marketing wiki pages for current release,start_features_cal,5,marketing
9,bug_trackers,Create Tracker Bugs,PlanningPhase_start,,pm
10,design_concept,Conceptual Design Phase,PlanningPhase_start,30,design
11,wallpaper_design,Wallpaper Design for Alpha,design_concept,35,design
12,supplement_wallpaper_start,Supplemental Wallpaper Process,PlanningPhase_start,,design
x12,supplement_wallpaper_end,Supplemental Wallpaper Process,package_supplemental_wallpaper,,design
13,supplement_wallpaper_submit,Supplemental Wallpaper Submission Period,PlanningPhase_start,82,
14,decide_supplement_wallpaper,Select Official Supplemental Wallpaper,supplement_wallpaper_submit,,
15,supplement_license_review,Verify Supplemental Wallpaper Licenses,decide_supplement_wallpaper,10,
16,package_supplemental_wallpaper,Package Supplemental Wallpaper,supplement_license_review,2,
17,DevelopmentPhase_start,Development Phase,,,
x17,DevelopmentPhase_end,Development Phase,develop,,
18,devel_start,Start Development,,,devel
19,develop,Packaging and Development \(precedes Alpha),,70,devel proto
20,TestingPhase_start,Testing Phase start,,,
x20,TestingPhase_end,Testing Phase end,,,
21,alpha_start,Alpha Release start,TestingPhase_start,,
24,alpha_blocker1,Alpha Blocker Meeting alpha 1,alpha_start,5,releng quality devel blocker pm
26,alpha_blocker2,Alpha Blocker Meeting alpha 2,alpha_blocker1,5,releng quality devel blocker pm
27,daily_alpha_blocker,Daily Review and Notification of Open Alpha Blocker Bugs,alpha_blocker2,4,releng quality devel pm blocker
29,alpha_blocker3,Alpha Blocker Meeting alpha 3,alpha_blocker2,5,releng quality devel pm blocker
31,alpha_blocker4,Alpha Blocker Meeting 4,alpha_blocker3,5,releng quality devel pm blocker
32,alpha_blocker5,Alpha Blocker Meeting alpha 5,alpha_blocker4,5,releng quality devel pm blocker
34,alpha_deadline_remind,Remind Alpha Deadline in 1 week,feature_freeze alpha_deadline,6,hidden pm
35,feature_freeze,Feature Freeze \(Testable/Complete),,,releng quality pm proto devel key marketing roadmap fpl
37,spins_freeze,Spins Freeze--All Spins Identified,,,releng quality pm proto devel key marketing spins fpl
38,talking_points,Create Talking Points,feature_freeze,5,marketing
39,feature_profiles,Feature Profiles,talking_points,20,marketing
40,branch_rawhide,Branch Fedora from Rawhide,,,releng devel pm proto key roadmap fpl
41,bugzilla_descrption,Reflect supported versions in Bugzilla product description,,,pm
42,rawhide_rebase,Rebase Rawhide bugs to Fedora,,,pm
44,feature_check_remind,Request Feature Status Updates and Remind Submit Deadline,,,devel pm
45,alpha_releng_tickets,File All Release Engineering Tickets for Alpha,,3,releng
46,feature_submit_remind_2_weeks,Feature Submission Deadline Two Weeks away,,6,devel pm
47,spins_wiki_update,Update All Spins Wiki Pages From Previous Releases,,,spins
48,feature_submit_remind_1_week,Feature Submission Deadline One Week away,,11,devel pm
49,alpha_installer_build1,Submit Installer Build for QA Compose,feature_submit_remind_1_week,1,devel
50,qa_alpha_compose1,Create Installable Images for QA testing #1,feature_submit_remind_1_week,2,releng
51,alpha_rawhide_install1,Pre-Alpha Rawhide Acceptance Test Plan #1,qa_alpha_compose1,6,quality
53,feature_submission_deadline,Feature Submission Deadline,,,releng quality pm proto devel key roadmap fpl
54,feature_submission_deadline_announce,Announce Feature Submission Closed,,,pm
55,spins_submission_deadline,Custom Spins Submission Deadline,,,pm proto key spins fpl
56,warn_rawhide_rebase,Rawhide Rebase Warning to Package Maintainers,,,pm
57,ticket_rawhide_rebase,File Rawhide Rebase ticket with RHT Eng-ops,,,pm
58,alpha_installer_build2,Submit Installer Build for QA Compose,feature_submission_deadline,2,devel
59,qa_alpha_compose2,Create Installable Images for QA testing 2,feature_submission_deadline,3,releng
60,alpha_rawhide_install2,Pre-Alpha Rawhide Acceptance Test Plan 2,qa_alpha_compose2,5,quality
61,alpha_installer_build3,Submit Installer Build for QA Compose,qa_alpha_compose2,4,devel
62,qa_alpha_compose3,Create Installable Images for QA testing 3,alpha_rawhide_install2,,releng
63,alpha_rawhide_install3,Pre-Alpha Rawhide Acceptance Test Plan 3,qa_alpha_compose3,5,quality
64,feature_incomplete_nag,Remind lt 85pct complete Feature Owners,feature_freeze,1,pm
65,feature_incomplete_fesco,Deliver Incomplete Features to FESCo,feature_freeze,6,pm
66,alpha_deadline,Alpha Change Deadline,develop,,releng quality pm devel key roadmap proto blocker spins
67,alpha_deadline_announce,Announce Alpha Change Deadline Reached,alpha_deadline,,pm
68,alpha_infrastructure_freeze,Alpha Infrastructure Change Freeze,alpha_deadline,10,infrastructure
69,alpha_spins_ks,Build spin-kickstarts package from master,alpha_deadline,,spins
70,orphan,Orphan Rawhide Packages,feature_freeze,,releng devel
71,finalize_alpha_wallpaper,Finalize Alpha Wallpaper,wallpaper_design,3,design pm
72,alpha_wallpaper_deadline,Alpha Wallpaper Deadline,finalize_alpha_wallpaper,,design
73,blog_alpha_wallpaper,Blog About Alpha Wallpaper,finalize_alpha_wallpaper,,design
74,package_alpha_wallpaper,Package Alpha Wallpaper,finalize_alpha_wallpaper,2,design
75,alpha_wallpaper_feedback,Solicit Feedback on Alpha Wallpaper,package_alpha_wallpaper,10,design
76,start_splash_screens,Create Splash Screens,alpha_drop,9,design
77,start_splash_screens_cal,Start Splash Screens,alpha_drop,,design
78,finalize_splash_screens,Finalize Splash Screens,start_splash_screens,4,design
79,beta_wallpaper,Prepare wallpaper for Beta,alpha_drop,13,design
81,alpha_go_not,Alpha Go/No-Go Meeting \(17:00 US Eastern),create_alpha_compose,4,releng quality devel pm proto blocker
82,trans_software_rebuild1,Remind f-dev-announce to Rebuild All Translated Packages,feature_freeze,5,translation
83,software_string_freeze,Software String Freeze,feature_freeze,6,devel translation pm proto releng key roadmap
85,software_translation,Software Translation,,,
86,trans_software,Software Translation Period,software_string_freeze,25,translation
88,request_review_image,Create Rel-Eng ticket for Live Image compose for Software Review UI,software_translation,4,translation
89,build_trans_software,Build F- collection packages for all language translators,request_review_image,,releng devel
90,compose_review_image,Compose of Live Image of Software Review UI for Translation,build_trans_software,,releng
91,trans_software_review,Review and correct software translation in built UI,build_trans_software,6,translation
92,trans_software_rebuild2,Remind f-dev-announce to Rebuild All Translated Packages,trans_software_review,,translation
93,trans_software_deadline,Software: Translation Deadline \(PO Files complete),trans_software_review,,translation roadmap key
94,start_trans_rebuild,Software: Start Rebuild all translated packages,trans_software_deadline,,devel
95,trans_rebuild,Software: Rebuild all translated packages,trans_software_deadline,5,devel
96,alpha_meeting_reminder,Reminder: Alpha Release Readiness Meeting,feature_freeze,10,pm
97,alpha_meeting,Alpha Release Readiness Meeting,alpha_meeting_reminder,3,releng pm quality docs design translation marketing web
98,create_alpha_tc,Create Alpha Test Compose \(TC),,,releng proto
99,test_alpha_tc,Test Alpha 'Test Compose',create_alpha_tc,6,quality proto
100,alpha_kernel_build,Submit Kernel Build for Alpha RC Compose,alpha_deadline,,devel
101,alpha_installer_build,Submit Installer Build for Alpha RC Compose,alpha_deadline,1,devel
103,create_alpha_compose,Compose Alpha Candidate,alpha_deadline,2,releng proto
104,test_alpha_candidate,Test Alpha Candidate,create_alpha_compose,5,quality proto
105,start_stage_alpha,Start Stage and Sync Alpha to Mirrors,test_alpha_candidate,,releng
106,notify_mirrors_alpha,Notify Mirrors of Alpha,start_stage_alpha,1,releng
107,stage_alpha,Stage and Sync Alpha to Mirrors,test_alpha_candidate,3,releng proto
108,alpha_export_control,Alpha Export Control Reporting,start_stage_alpha,1,releng pm
109,alpha_announce,Create Alpha Announcement \(Marketing and Docs),alpha_meeting,2,docs marketing
110,alpha_banner,Alpha Release Banner,,3,
111,alpha_create_banner,Create Alpha Website Banner,,2,design
112,alpha_publish_banner,Add Alpha Banner to Website,alpha_create_banner,1,web
113,alpha_drop,Alpha Public Availability,stage_alpha alpha_banner alpha_publish_banner,,releng docs quality design pm proto devel key marketing roadmap spins blocker infrastructure fpl
114,ambassador_start,FAmSCo heads Ambassador Wide Meetings Preparing For,alpha_drop,7,amassadors
115,start_swag,FAmSCo and Regional teams call for Preparation of Media/SWAG,alpha_drop,7,ambassadors
116,swag_poc,Regional Team Meetings and Select POC for Swag/Media production,alpha_drop,8,ambassadors
117,swag_funding_request,Regional Teams Submit Funding Request For Swag/Media Production,alpha_drop,8,amassadors
118,nvr_testing,NVR Update Check testing,stage_alpha,1,quality
119,alpha_release_notes,Alpha Release Notes,,,
120,start_alpha_beats,Start Alpha Beat and Feature Page Review,feature_freeze,6,docs quality
121,validate_beat_writers,Validate Former Beat Writers,feature_freeze,5,docs
122,recruite_beat_writers,Recruit New Beat Writers,validate_beat_writers,5,docs
123,comb_alpha_beats,Comb Beats and Feature Pages for Alpha,start_alpha_beats,2,docs quality
124,notify_devel_relnotes,Notify Development About Alpha Release Notes,alpha_deadline,,docs
125,prep_alpha_notes,Prepare Alpha Release Notes \(1 page),comb_alpha_beats,6,docs quality
126,post_notes,Post Alpha Release Notes One-Page,prep_alpha_notes,1,docs
127,test_alpha,Alpha Testing,stage_alpha,15,quality proto
128,review_bookmarks,Review Firefox Bookmarks For Update,stage_alpha,5,marketing
129,update_bookmarks,Update and Package Firefox Bookmarks,review_bookmarks,2,marketing
130,tag_bookmarks,Tag Updated Bookmarks Package for,update_bookmarks,,marketing
131,alpha_end,End of Alpha Testing,test_alpha,,quality
132,beta_marketing_notes,Marketing: Beta One Page Release Notes,alpha_end,5,marketing
133,beta,Beta Release,,,
134,remind_beta_blocker1,Reminder: Beta Blocker Meeting \(beta) 1,create_alpha_compose,9,pm
135,beta_blocker1,Beta Blocker Meeting \(beta) 1,stage_alpha,3,quality releng devel pm blocker
136,beta_releng_tickets,File All Release Engineering Tickets for Beta,stage_alpha,2,releng
137,remind_beta_blocker2,Reminder: Beta Blocker Meeting \(beta) #2,beta_blocker1,3,pm
138,beta_blocker2,Beta Blocker Meeting \(beta) 2,beta_blocker1,5,releng quality devel pm blocker
139,daily_beta_blocker,Daily Review and Notification of Open Beta Blocker Bugs,beta_blocker2,4,releng quality devel pm blocker
141,beta_blocker3,Beta Blocker Meeting \(beta) #3,beta_blocker2,5,releng quality devel pm blocker
143,beta_blocker4,Beta Blocker Meeting \(beta) #4,beta_blocker3,5,releng quality devel pm blocker
146,beta_spins_ks,Build spin-kickstarts package from master,,,spins
147,coordinate_swag_design,FAmSCo Coordinate Media/Swag/Poster artwork with Design team,,10,ambassadors
150,beta_deadline,Beta Change Deadline,test_alpha,,releng docs quality pm proto devel key marketing spins roadmap
151,feature_complete,Features 100% Complete Deadline,test_alpha,,releng docs quality pm proto devel key marketing roadmap fpl
152,beta_infrastructure_freeze,Beta Infrastructure Change Freeze,test_alpha,10,infrastructure releng
154,final_feature_fesco,Deliver features < 100% to FESCo,beta_deadline,1,pm
155,brief_ambassadors,Brief Ambassadors on upcoming release,beta_deadline,5,marketing
156,create_countdown,Create Count Down Graphic,beta_deadline,10,design
157,publish_countdown,Publish Count Down Graphic,create_countdown,1,web
158,beta_release_notes,Beta Release Notes,,,
159,unclaimed_beats,Write Unclaimed Wiki Beats,alpha_drop,6,docs
160,port_wiki_publican,Port Wiki to Publican,unclaimed_beats,3,docs
162,start_release_notes_pot1,Start nightly POT files all fed-rel-notes.rpm content,port_wiki_publican,1,docs
163,release_notes_pot1,Generate nightly POT files all fed-rel-notes.rpm content,port_wiki_publican,13,docs
165,beta_wiki_freeze,Wiki Freeze: Beta Release Notes,beta,2,docs
166,trans_release_notes,Translate Beta Release Notes,port_wiki_publican,14,translation
167,build_trans_review,Ongoing build translation review htmls,beta_wiki_freeze,5,docs
168,trans_review_beta,Review and correct Beta Release Notes \(daily buids html),beta_wiki_freeze,5,translation
169,trans_release_notes_deadline,Translation Deadline: Beta Release Notes \(PO Files complete),trans_review_beta,,translation docs
170,build_beta_relnotes,Build f-r-n.rpm and Push to updates-candidate,trans_release_notes_deadline,2,docs translation
171,final_release_notes_reminder,Reminder: Send Project Wide-Final Release Notes Deadlines,beta_deadline,7,docs
172,web_notes,Build and Post Beta release-notes to docs.fedoraproject.org,beta_meeting,2,docs
173,tech_web_notes,Build and Post Fedora Technical Notes to docs.fedoraproject.org,beta_meeting,2,docs
174,splash_deadline,Deadline: Beta Splash Screens,finalize_splash_screens,,design
175,package_final_splash,Package: Beta Splash Screens,finalize_splash_screens,2,design
176,package_beta_wallpaper,Package: Beta Wallpaper,beta_wallpaper,2,design
177,package_supplemental_wallpaper,Package: Supplemental Wallpaper,beta_wallpaper,,design
178,beta_meeting_announce,Announce: Beta Release Readiness Meeting,,,pm
179,beta_meeting_reminder,Reminder: Beta Release Readiness Meeting,beta_deadline,4,pm
180,beta_meeting,Beta Release Readiness Meeting,beta_meeting_reminder,3,releng pm quality docs design translation marketing web
181,beta_announce,Create Beta Announcement \(Docs and Marketing),beta_meeting,2,docs marketing
182,beta_installer_build1,Submit Installer Build for Beta TC Compose,,,devel
183,beta_rawhide_install,Pre-Beta Acceptance Test Plan,,5,quality
184,create_beta_tc,Create Beta Test Compose \(TC),beta_rawhide_install,2,releng proto
185,test_beta_tc,Test Beta 'Test Compose',create_beta_tc,6,quality proto
187,beta_go_not,Beta Go/No-Go Meeting \(17:00 US Eastern),create_beta_compose,4,releng quality devel pm proto blocker
188,beta_kernel_build,Submit Kernel Build for Beta RC Compose,beta_deadline,,devel
189,beta_installer_build,Submit Installer Build for Beta RC Compose,beta_deadline,1,devel
191,create_beta_compose,Compose Beta Candidate,beta_deadline,2,releng proto
192,call_for_events,FAmSCo and Regional Teams Call for Release Events,beta_deadline,12,ambassadors
193,logistics_budget,Regional Teams Plan Regional Logistics for Release Events and File Budget Requests,call_for_events,10,ambassadors
194,test_beta2,Test Beta Candidate,create_beta_compose,5,quality proto
195,start_stage_beta,Start Stage and Sync Beta to Mirrors,test_beta2,,releng
196,notify_mirrors_beta,Notify Mirrors of Beta,start_stage_beta,1,releng
197,stage_beta,Stage and Sync Beta to Mirrors,test_beta2,3,releng proto
198,beta_export_control,Beta Export Control Reporting,start_stage_beta,1,releng pm
199,beta_banner,Beta Release Banner,,3,
200,beta_create_banner,Create Beta Website Banner,,2,design
201,beta_publish_banner,Add Beta Banner to Website,beta_create_banner,1,web
203,beta_drop,Beta Release Public Availability,stage_beta beta_create_banner beta_publish_banner,,docs releng quality pm translation proto design devel key marketing roadmap blocker spins infrastructure fpl
204,event_deadline,Release Event Submission Deadline,logistics_budget,1,ambassadors
205,budget_allocations,FAmSCo Review Budget Allocations,event_deadline,,ambassadors
206,irc_sessions,FAmSCo Regional IRC town halls,beta_drop,10,ambassadors
207,beta_test,Beta Testing,stage_beta,14,quality proto
208,websites_trans_reminder,Reminder to f-websites-list about POT/PO dates in 7 days,beta_drop,,translation web
209,media,Create DVD/CD label and sleeve artwork,beta_drop,10,design
210,rc_rawhide_install,Pre-RC Acceptance Test Plan,stage_beta,7,quality
211,testmile,End of Beta Testing,beta_test,,quality
212,LaunchPhase,Launch Phase,,,
213,release_posters,Release Party Posters,beta_drop,,
214,create_posters,FAmSCo with Design Team Create Release Party Posters,,10,ambassadors
215,polish_poster,Polish/Finalize Release Party Posters,create_posters,9,design
216,screenshots,Update and freeze the screenshots page,stage_beta,5,marketing
217,final_screenshots,Marketing: Final Screen Shots,screenshots,5,marketing
218,final_marketing_notes,Marketing: Final One Page Release Notes,screenshots,5,marketing
219,briefings,Brief news distribution network,screenshots,5,marketing
220,monitor,Monitor news sites to provide corrections and info,screenshots,29,marketing
221,rc,Release Candidate,,,
222,final_releng_tickets,File All Release Engineering Tickets for GA,stage_beta,2,releng
224,ga_blocker1,Final Blocker Meeting \(blocker) #1,start_stage_beta,1,releng quality devel pm blocker
226,ga_blocker2,Final Blocker Meeting \(blocker) #2,ga_blocker1,5,releng quality devel pm blocker
228,ga_blocker3,Final Blocker Meeting \(blocker) #3,ga_blocker2,5,releng quality devel pm blocker
229,kernel_debug,Disable Kernel debug and submit new Kernel build for RC,,,devel
231,final_change_deadline,Final Change Deadline,beta_test,,releng devel proto pm key spins
232,check_swag,FAmSCo and Regional Teams Meet to Address Unresolved Events/Media/Swag Issues,final_change_deadline,1,ambassadors
233,final_wallpaper,Package Final Wallpaper,,,design
234,final_splash,Package Final Splash Screens,,,design
235,announce_final_change_deadline,Announce Final Freeze and Implications,final_change_deadline,,pm
236,eol_warning,File RHT Eng-ops ticket for Fedora 15 EOL Bugzilla warning,final_change_deadline,,pm
237,final_infrastructure_freeze,Final Infrastructure Change Freeze,beta_test,10,infrastructure releng
239,ga_blocker4,Final Blocker Meeting \(blocker) #4,ga_blocker3,5,releng quality devel pm blocker
240,daily_ga_blocker,Daily Review and Notification of Open Final Blocker Bugs,ga_blocker3,4,releng quality devel pm blocker
241,ga_blocker5,Final Blocker Meeting \(blocker)--Blocks RC Compose,ga_blocker4,1,releng quality devel pm blocker
242,ga_release_notes,Final Release Notes,,,
243,final_release_note_wiki_reminder,Reminder to Development: Wiki Freeze in 7 days,,,docs
244,prep_ga_notes,Prepare GA Release Notes,beta_drop,,docs quality
245,ga_release_notes_freeze,String Freeze: GA Release Notes,prep_ga_notes,4,docs
246,wiki_ga_port,Port diff wiki content to Publican,ga_release_notes_freeze,5,docs
248,ga_pot_trans,Translate Final Release Notes \(POT to PO),beta_release_notes trans_release_notes_deadline,24,translation
249,ga_release_notes_pot,Generate GA Release Notes POT files for Translation,wiki_ga_port,,docs
250,build_trans_review_final,Build GA release note htmls for Translation,ga_release_notes_pot,4,docs
251,build_ga_trans_review,Review and correct GA Release Notes \(daily builds html),ga_release_notes_pot,4,docs translation
253,ga_release_notes_po,Translation Deadline: GA rel-notes \(PO Files complete),ga_pot_trans,,translation
254,ga_release_notes_rpm,Build fedora-release-notes.rpm,ga_release_notes_po,2,docs
255,ga_create_banners,Create Final Release Banners,testmile,9,design
256,create_ga_announce,Create GA Announcement \(Docs and Marketing),,7,docs marketing
257,translate_ga_announce,GA Announcement available for translation \(optional),create_ga_announce,5,translation
258,ga_publish_banners,Add Final Release Banners to Website,ga_create_banners,1,web
259,web_content_update,Update Website Content,beta_drop,5,web
260,web_freeze,Website String Freeze,web_content_update,,web
261,web_create_pot,Create Website POT Files,web_freeze,1,web
262,trans_web,Translation Period for Website \(POT to PO),web_create_pot,9,translation
263,review_trans_web,Review and correct Website translations,trans_web,4,translation web
264,finish_trans_web,Translation Deadline: Websites \(POs done),review_trans_web,,translation
265,publish_trans_web,Publish Translations on Website \(fedoraproject.org),review_trans_web,1,web
266,final_meeting_reminder,Reminder: Final Release Readiness Meeting,beta_test,5,pm
267,ga_meeting,Final Release Readiness Meeting,final_meeting_reminder,3,releng pm quality docs design marketing translation web
268,final_installer_build1,Submit Installer Build for Final TC Compose,,,devel
269,create_final_tc,Create 'Final' Test Compose \(TC),,2,releng proto
270,test_final_tc,Test 'Final' Test Compose \(TC),create_final_tc,4,quality proto
271,final_installer_build,Submit Installer Build for Final RC Compose,final_change_deadline,,devel
273,start_final_compose,Compose 'Final' RC: DVD;Live;Spins,final_change_deadline,1,releng key roadmap proto
274,early_iso,Regional Teams Obtain Final Release ISOs from Release Engineering for duplication,test_final,3,ambassadors
275,regional_marketing,Regional Coordination with Marketing for Release Events,test_final,5,ambassadors
276,deliver_final,Deliver RC to QA for Testing,start_final_compose,,releng proto
277,test_final,Test 'Final' RC,deliver_final,4,quality
278,start_stage_final,Start Stage and Sync RC to Mirrors,test_final,2,releng
279,notify_mirrors_final,Notify Mirrors of Final,start_stage_final,1,releng
280,stage_final,Stage and Sync RC to Mirrors,test_final,3,releng proto
281,package_spins_ks,Branch spin-kickstarts and build package from new branch,create_final_tc,,spins
282,freeze_spins_ks,Spins kickstart package Freeze,create_final_tc,,spins
283,enable_updates,Enable Updates,beta_test,2,releng
285,final_go_not,Final Go/No-Go Meeting \(17:00 US Eeastern),start_final_compose,4,releng quality docs pm proto blocker
286,final_export_control,Final Export Control Reporting,start_stage_final,1,releng pm
287,bugzilla_descrption,Reflect supported versions in Bugzilla product description,stage_final,,pm
288,zero_day_relnotes,Zero Day Release Notes,beta_drop,,
290,zero_day_web,0-Day rel-notes update docs.fp.org,zero_day_relnotes,6,docs
291,zero_day_rpm,0-Day rel-notes build updated rpm,zero_day_relnotes,6,docs
292,zero_day_pot,0-Day rel-notes generate POT,zero_day_relnotes,6,docs
293,zero_day_trans,Translate 0-Day Release Notes,zero_day_relnotes,6,translation
294,zero_day_deadline,Translation Deadline: 0-Day \(PO Files complete),zero_day_trans,10,translation
295,web_post,Add translated zero-day updates to docs.fp.org,zero_day_trans,,docs
296,post_tech_notes,Update and post Fedora Technical Notes to docs.fedoraproject.org,final,,docs
297,push_updates_rpm,Push updated rel-notes RPMs to Updates repo,final,4,docs
300,final,Final \(GA) Release,stage_final zero_day_relnotes media_prebriefs,,quality releng docs design pm translation proto devel key marketing roadmap spins infrastructure fpl
302,event_reports,Hold Release Events and Publish Event Reports,final,23,ambassadors
303,spins_ga_ks,Build new spin-kickstarts package for updates \(if necessary),stage_final,,spins
304,marketing_post,Marketing Retrospective,final,10,marketing
305,all_guides,Guides,,,
306,continue_guides_trans,Continue translation of guides in branch of previous release,,70,translation
307,test_branch_guides,Test master branches of guides against Alpha and correct,stage_alpha,10,docs
308,branch_guides,Branch Guides,test_branch_guides,,docs
309,guides_pot,Create POT files for All Guides,branch_guides,,docs
310,notify_trans,Notify trans that new Guide POT files available,guides_pot,,docs
311,trans_all_guides,Translate All Guides \(POT to PO),guides_pot,,docs
312,publish_draft,Publish draft guides,branch_guides,,docs
313,annouce_publish_draft,Notify announce-list and f-devel-list draft guides available,publish_draft,,docs
314,guides_trans,Translate All Guides \(POT to PO),guides_pot,39,translation
316,srpm_review,Remind new guide owners SRPM package review,beta_deadline,6,docs
318,guides_string_freeze,String Freeze All Guides,final_change_deadline,,docs
319,generate_final_pot,Generate final POT files for Guides,guides_string_freeze,,docs
320,notify_trans_final,Notify Trans of Final Guides POT availability,guides_string_freeze,,docs
321,build_daily,Daily builds of Final guides for Translation,final_change_deadline,9,docs
322,review_daily,Review and correct Final Translated Guides \(daily builds html),final_change_deadline,9,translation
323,guides_trans_deadline,Translation Deadline: All Final Guides,,,translation
324,test_guides_beta,Test guides against Beta and correct,beta_drop,4,docs
325,refresh_pot,Refresh POT files for all guides against Beta,test_guides_beta,,docs
326,notify_trans_refresh,Notify trans that POT files updated against Beta,refresh_pot,,docs
327,republish_draft,Republish draft guides for Beta,test_guides_beta,,docs
328,notify_revised_draft,Notify announce-list and f-devel-list revised draft guides available,republish_draft,,docs
329,guides_final_build,Final Build All Guides: All Languages,srpm_review,3,docs
330,publish_guides,Publish all guides to docs.fp.o \(html;html-single;pdf),,,docs
331,elections,Election Coordination,,,elections fpl pm
332,remind,Remind advisory-board list of upcoming election schedule,,,
333,solicit,Solicit volunteers for questionnaire and town halls,remind,7,
334,wiki_update,Update wiki page https://fedoraproject.org/wiki/Elections with required information,solicit,,
335,advertise_elections,Advertise elections schedule and pages,solicit,,
336,announce_nominations,FPL/designee announces opening of nominations,solicit,25,
337,open_questions,Questionnaire wrangler announces opening for questions,announce_nominations,,
338,collect_questions,Collect question on the wiki,announce_nominations,8,
339,collect_answers,Candidates write questionnaire answers,collect_questions,7,
340,announce_town,Town hall wrangler announces schedule for town hall meetings,announce_nominations,,
341,question_deadline,Questionnaire answers due from candidates,collect_answers,,
342,present_answers,Wrangler presents questionnaire answers,collect_answers,2,
343,post_questions,All answers posted to questionnaire page;advertise to voters,present_answers,,
344,town_hall,Town hall period,post_questions,6,
345,voting_application,Finalize Voting Application,town_hall,1,
346,voting_start,Voting Begins,voting_application,,
347,voting,Voting for general elections,voting_application,6,
348,voting_end,Voting Ends,voting,,
349,announce_results,Announce Results,voting_end,1,
350,naming,Name the Release,,,pm fpl
351,gather,Collect Names on Wiki,,5.5,
352,board,Board Review of Proposed Names,gather,3,
353,legal,Legal Review,board,5,
354,vote,Voting,legal,4,
355,announce_name,Release Name Announced,vote,1,design pm
356,pr,Public Relations,,,
357,video,Creative team videos,,25,fpl pr
358,video_schedule,Meet w/Creative to schedule videos,,5,
359,video1,Make spotlight video 1,video_schedule,,
360,review_spotlight1_video,Review video #1,video1,15,
361,release_spotlight1_video,Publish spotlight video #1,review_spotlight1_video,,
362,video2,Make spotlight video #2,video_schedule,,
363,review_spotlight2_video,Review video #2,video2,15,
364,release_spotlight2_video,Publish spotlight video #2,review_spotlight2_video,,
365,review_release_video,Make and Review release video,video1 video2,20,
366,release_video,Publish release video,final review_release_video,,
367,beta_release_blog,Beta press blog entry,,,fpl pr
368,beta_release_blog_draft,Start drafting Beta blog,,10,
369,beta_release_blog_legal,Red Hat PR send Beta blog to Legal,beta_release_blog_draft,5,
370,beta_release_blog_intl,Red Hat PR send Beta blog to intl-pr list,beta_release_blog_legal,6,
371,beta_release_blog_drop,Red Hat PR publish and send Beta blog to media contacts,beta_drop beta_release_blog_intl,,
372,spotlight_feature1_draft,Draft spotlight #1 blog entry,,5,fpl pr
373,spotlight_feature1_legal,Red Hat PR send spotlight #1 blog entry draft to legal,spotlight_feature1_draft,5,fpl pr
375,spotlight_feature1_drop,Red Hat PR publish spotlight #1 blog entry,spotlight_feature1_legal,,fpl pr
376,spotlight_feature1,Spotlight feature #1,spotlight_feature1_drop,,
377,spotlight_feature2_draft,Draft spotlight #2 blog entry,,5,fpl pr
378,spotlight_feature2_legal,Red Hat PR send spotlight #2 blog entry draft to legal,spotlight_feature2_draft,5,fpl pr
379,spotlight_feature2_drop,Red Hat PR publish spotlight #2 blog entry,,,fpl pr
381,spotlight_feature2,Spotlight feature #2,spotlight_feature2_drop,,
382,spotlight_feature3,Spotlight feature #3,,,
383,spotlight_feature3_draft,Draft spotlight #3 blog entry,,5,fpl pr
384,spotlight_feature3_legal,Red Hat PR send spotlight #3 blog entry draft to legal,spotlight_feature3,5,fpl pr
385,spotlight_feature3_drop,Red Hat PR publish spotlight #3 blog entry,spotlight_feature3_legal,,fpl pr
387,spotlight_feature_blogs,Spotlight feature press blogs,spotlight_feature3 spotlight_feature2 spotlight_feature1,,
388,usb_keys_prebriefs,USB Keys and media pre-briefs,,,fpl pr
389,buy_usb_keys,Purchase USB Keys,,5,
390,assess_press_kit,Check LiveUSB press review sheet for readiness,,5,
391,update_press_one_sheet,Update LiveUSB press review sheet,assess_press_kit,5,
392,prepare_usb_keys,Prep USB keys with pre-release,buy_usb_keys,5,
393,send_usb_keys,Send USB keys to Red Hat PR for distribution,prepare_usb_keys update_press_one_sheet,10,
394,distribute_usb_keys,Red Hat PR distribute USB keys to media contacts,,7,
395,media_prebriefs,Hold media prebrief interviews,send_usb_keys distribute_usb_keys,6,
396,web_graphics_discuss,Schedule meeting with Red Hat web team to plan launch,,5,
397,web_promo_to_brand,Send web promo ideas to Brand,web_graphics_discuss,5,
398,web_copy_review,Review and update www.redhat.com/Fedora copy,web_promo_to_brand,5,
399,web_copy_send_update,Send updated copy to Web team,web_copy_review,11,
400,rh_web_goes_live,Red Hat website changes go live,final web_copy_send_update,,
401,redhat_com_update,Update Red Hat web site,rh_web_goes_live,,fpl pr
402,ga_press_release_draft,Start drafting GA press release,,10,
403,ga_press_release_legal,Red Hat PR send GA press release to Legal,ga_press_release_draft,5,
404,ga_press_release_intl,Red Hat PR send GA press release to intl-pr list,ga_press_release_legal,6,
405,ga_press_release_drop,Red Hat PR publish and send GA press release to media contacts,final ga_press_release_intl,,
406,ga_press_release,GA press release,ga_press_release_drop,,fpl pr
407,ceo_prepare_final_rc,Prepare a final RC on USB for CEO,,2,
408,ceo_send_final_rc,Send final RC USB key to CEO,ceo_prepare_final_rc,2,
409,ceo_solicit_feedback,Solicit CEO feedback on pre-release,ceo_send_final_rc,4,
410,ceo_blog_draft,Draft CEO blog,ceo_solicit_feedback,3,
411,ceo_blog_legal,Red Hat PR send CEO blog to Legal,ceo_blog_draft,3,
412,ceo_blog_drop,Red Hat PR publish and send CEO blog to media contacts,final ceo_blog_legal,1,
413,ceo_blog,CEO press blog entry,ceo_prepare_final_rc ceo_send_final_rc ceo_solicit_feedback ceo_blog_drop,,fpl pr
"] }
        p20f {
            set ret_list [list "Example 6" "This example highlights features that somewhat resemble the XDCPM banner." "activity_ref,dependent_tasks,time_est_median
AA,,100
BB,AA,100
CC,BB,100
DD,CC,100
EE,DD,100
FF,EE,100
GG,FF,100
HH,GG,100
II,HH,100
JJ,,100
KK,JJ,100
LL,KK,100
MM,LL,100
NN,MM,100
OO,NN,100
PP,OO,100
QQ,PP,100
RR,,90
SS,KK,100
TT,JJ,90
UU,LL,100
VV,MM,100
WW,NN,90
XX,OO,90
YY,PP,100
ZZ,SS,100
AE,TT,90
OE,UU,100
OU,VV,100
EU,WW,90
US,XX,90
DK,YY,100
G1,RR,12
G2,G1,10.8
G3,G2,9.72
G4,G3,8.748
G5,G4,7.8732
G6,G5,7.08588
G7,G6,6.377292
G8,G7,5.7395628
H1,AE,53
H2,H1,47.7
H3,H2,42.93
H4,H3,38.637
H5,H4,19
H6,H5,32
J1,ZZ,28.8
J2,J1,25.92
J3,J2,23.328
J4,J3,20.9952
J5,J4,18.89568
L1,OE,17.006112
L2,L1,15.3055008
L3,L2,13.77495072
L4,L3,12.397455648
K1,OU,11.1577100832
K2,K1,10.0419390749
K3,K2,9.0377451674
INT,EU,28
ORG,INT,28
UK,QQ,90
RI,US,23" ]
        }
        p30g {
            set ret_list [list "example p3" "This is an example p3 using example 1's data templated into p3 format" "type,time_est_short,time_est_median,time_est_long,time_ext,dependent_tasks
A,2,4,6,4.0,
B,3,5,9,5.33,
C,4,5,7,5.17,A
D,4,6,10,6.33,A
E,4,5,7,5.17,B C
F,3,4,8,4.5,D
G,3,5,8,5.17,E" ]
        }

        p20 {
            # p2 Task Network
            #      activity_ref           reference for an activity, a unique task id, using "activity" to differentiate between table_id's tid 
            #                             An activity reference is essential a function as in f() with no attributes,
            #                             However, there is room to grow this by extending a function to include explicitly set paramemters
            #                             within the function, similar to how app-model handles functions aka vectors
            #                             The multiple of an activity is respresented by a whole number followed by an "*" 
            #                             with no spaces between (when spaces are used as an activity delimiter), or
            #                             with spaces allowed (when commas or another character is used as an activity delimiter.
            #                
            #      aid_type               activity type from p3
            #      dependent_tasks        direct predecessors , activity_ref of activiites this activity depends on.
            #      name                   defaults to type's name (if exists else blank)
            #      description            defaults to type's description (if exists else blank)
            #      max_concurrent         defaults to type's max_concurrent 
            #      max_overlap_pct     defaults to type's max_overlap_pct021
            
            #      time_est_short         estimated shortest duration. (Lowest statistical deviation value)
            #      time_est_median        estimated median duration. (Statistically, half of deviations are more or less than this.) 
            #      time_est_long          esimated longest duration. (Highest statistical deviation value.)
            #      time_dist_curve_tid Use this distribution curve instead of the time_est short, median and long values
            #                             Consider using a variation of task_type as a reference
            #      time_dist_curv_eq  Use this distribution curve equation instead.
            
            #      cost_est_low           estimated lowest cost. (Lowest statistical deviation value.)
            #      cost_est_median        estimated median cost. (Statistically, half of deviations are more or less than this.)
            #      cost_est_high          esimage highest cost. (Highest statistical deviation value.)
            #      cost_dist_curve_tid Use this distribution curve instead of equation and value defaults
            #      cost_dist_curv_eq  Use this distribution curve equation. 
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_point in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_point in c_est_arr
            set ret_list acc_fin::pretti_columns_list p2 0
            
        }
        p21 {
            set ret_list acc_fin::pretti_columns_list p2 1
        }
        p30 {
            # p3 Task Types:   
            #      type
            #      dependent_types      Other dependent types required by this type. (possible reference collisions. type_refs != activity_refs.
            #
            #####                       dependent_types should be checked against activity_dependents' types 
            #                           to confirm that all dependencies are satisified.
            #      name
            #      description
            #      max_concurrent       (as an integer, blank = no limit)
            #      max_overlap_pct021  (as a percentage from 0 to 1, blank = 1)
            #
            #      RESERVED columns:
            #      _tCurveRef             integer reference to time curve in time_clarr and   time duration estimate at time_probability_point in t_est_arr
            #      _cCurveRef             integer reference to cost curve in cost_clarr and   cost duration estimate at cost_probability_point in c_est_arr
            set ret_list acc_fin::pretti_columns_list p3 0
        }
        p31 {
            set ret_list acc_fin::pretti_columns_list p3 1
            # if changing p3 or p2 lists, see also constants_woc_list in this file.
        }
        p40 {
            # each column is track_{number} and generated by code so not used in this context

            # p4 Display modes
            #  
            #  tracks within n% of CP duration, n represented as %12100 or a duration of time as total lead slack
            #  tracks w/ n fixed count closest to CP duration. A n=1 shows CP track only.
            #  tracks that contain at least 1 CP track 
            set ret_list acc_fin::pretti_columns_list p4 0
        }
        p41 {
            # each column is track_{number} and generated by code so not used in this context
            set ret_list acc_fin::pretti_columns_list p4 1
        }
        p50 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list acc_fin::pretti_columns_list p5 0
        }
        p51 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. 
            set ret_list acc_fin::pretti_columns_list p5 1
        }
        p60 {
            # each row is a cell, in format of detailed PRETTI internal output. See code. All columns are required to reproduce output to p4 (including p4 comments).
            set ret_list acc_fin::pretti_columns_list p6 0
        }
        p61 {
            # each row is a path, in format of detailed PRETTI internal output. See code. 
            set ret_list acc_fin::pretti_columns_list p6 1
        }
        dc0 {
            # dc2 distribution curve table
            #                   Y         where Y = f(x) and f(x) is a 
            #                             probability mass function ie probability density function as a distribution
            #                             http://en.wikipedia.org/wiki/Probability_mass_function
            #                             http://en.wikipedia.org/wiki/Probability_density_function
            #                         aka http://en.wikipedia.org/wiki/Discrete_probability_distribution#Discrete_probability_distribution
            #                             The discrete values are the values of Y included in the table
            
            #                    X        Where X = the probability of Y.
            #                             These can be counts of a sample or a frequency.  When the table is saved,
            #                             the total area under the distribution is normalized to 1.
            
            #                   label     Where label represents the value of Y at x. This is a short phrase or reference
            #                             that identifies a boundary point in the distribution.
            # A three point (short/median/long or low/median/high) estimation curve can be respresented as
            # a discrete set of six points:  minimum median median median median maximum 
            # of standard bell curve probabilities (outliers + standard deviation).
            # Thereby allowing *_probability_point variable to be used in estimates with lower statistical resolution.
            set ret_list acc_fin::pretti_columns_list dc 0
        }
        dc1 {
            set ret_list acc_fin::pretti_columns_list dc 1
        }
        default {
            ns_log Notice "acc_fin::pretti_columns_list (242): bad reference sref '$sref'. Returning blank list."
            set ret_list [list ]
        }
    }
    return $ret_list
}

ad_proc -private acc_fin::pretti_example_maker {
    {name_value_list ""}
    {package_id ""}
    {user_id ""}
} {
    Creates a randomized scenario with accompanying required tables, mainly used for testing. Pass a list of optional arguments as a list of name-value pairs; See code for options.
} {
    set randomseed [expr { wide( [clock seconds] / 360 ) }] 
    #set random [expr { wide( fmod( $random * 38629 , 279470273 ) * 71 ) } ]
     set random [expr { srand($randomseed) } ]


    # scenario_prettify requires:
    # p1 scenario table
    # p2 activity table
    # optional:
    # p3 activity_type table
    # dc distribution curves
    
    # p1 data refers to p2 table. Create p2 table before p1.
    # p2 data refers to dc or p3 tables. Create dc or p3 tables before p2.

    # acts = accounts count
    # cols = columns count
    # types = types count
    # dots = points count
    set dc1_list [acc_fin::pretti_columns_list dc 1]
    set dc1_len [llength $dc1_list]
    set dc0_list [acc_fin::pretti_columns_list dc 0]
    set dc0_len [llength $dc0_list]
    set p11_list [acc_fin::pretti_columns_list p1 1]
    set p11_len [llength $p11_list]
    set p10_list [acc_fin::pretti_columns_list p1 0]
    set p10_len [llength $p10_list]
    set p21_list [acc_fin::pretti_columns_list p2 1]
    set p21_len [llength $p21_list]
    set p20_list [acc_fin::pretti_columns_list p2 0]
    set p20_len [llength $p20_list]
    set p31_list [acc_fin::pretti_columns_list p3 1]
    set p31_len [llength $p31_list]
    set p30_list [acc_fin::pretti_columns_list p3 0]
    set p30_len [llength $p30_list]

    set param_arr(dc_count_min) 0
    set param_arr(dc_count_max) 5
    set param_arr(dc_count) [expr { int( [util::random] * ( $param_arr(dc_count_max) - $param_arr(dc_count_min) ) + .99 ) + $param_arr(dc_count_min) } ]
    set param_arr(dc_dots_min) 0
    set param_arr(dc_dots_max) 10
    set param_arr(dc_cols_min) $dc1_len
    set param_arr(dc_cols_max) $dc0_len

    
    set param_arr(p3_types_min) 0
    set param_arr(p3_types_max) 120
    set param_arr(p3_cols_min) $p31_len
    set param_arr(p3_cols_max) $p30_len
#    set param_arr(p3_cols) [expr { int( [util::random] * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]

    set param_arr(p2_acts_max) 100
    set param_arr(p2_acts_min) 20
    set param_arr(p2_cols_min) $p21_len
    set param_arr(p2_cols_max) $p20_len
#    set param_arr(p2_cols) [expr { int( [util::random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]

    set param_arr(p1_vals_min) $p11_len
    set param_arr(p1_vals_max) $p10_len
#    set param_arr(p1_vals) [expr { int( [util::random] * ( $param_arr(p1_vals_max) - $param_arr(p1_vals_min) + .99 ) ) + $param_arr(p1_vals_min) } ]

    # blank means column inclusion is randomized. Otherwise list specific columns to try/use
    # acc_fin::pretti_columns_list is a handy column name reference
    set param_arr(p1_req_vals) ""
    set param_arr(p2_req_cols) ""
    set param_arr(p3_req_cols) ""
    # Use an existing case to test..??? not implemented.

    # Add optional arguments
    # ie generative parameters
    foreach {name value} $name_value_list {
        if { [info exists param_arr($name) ] } {
            set param_arr($name) $value
        }
    }
    
    # dc
    ns_log Notice "acc_fin::pretti_example_maker.248 dc start"
    for {set i 0} { $i < $param_arr(dc_count) } { incr i } {
        set dc_larr($i) [list ]
        set param_arr(dc_cols) [expr { int( [util::random] * ( $param_arr(dc_cols_max) - $param_arr(dc_cols_min) + .99 ) ) + $param_arr(dc_cols_min) } ]
        set title_list $dc1_list
        set cols_diff [expr { $param_arr(dc_cols) -  [llength $title_list] } ]
        if { $cols_diff > 0 } {
            lappend title_list [lindex $dc0_list end]
        }
        set title_list [acc_fin::shuffle_list $title_list]
        lappend dc_larr($i) $title_list
        set param_arr(dc_dots) [expr { int( [util::random] * ( $param_arr(dc_dots_max) - $param_arr(dc_dots_min) + .99 ) ) + $param_arr(dc_dots_min) } ]
        for { set ii 0} {$ii < $param_arr(dc_dots)} {incr ii} {
            # dist curve point
            set row_list [list ]
            foreach title $title_list {
                switch -exact $title {
                    x { 
                        # a random amount, assume hours for a task for example
                        set dot(x) [expr { int( [util::random] * 256. + 5. ) / 6. } ]
                    }
                    y {
                        # these could be usd or btc for example
                        set dot(y) [expr { int( [util::random] * 30000. + 90. ) / 100. } ]
                    }
                    label {
                        set dot(label) [ad_generate_random_string]
                    }
                }
                lappend row_list $dot($title)
            }
            # add row
            lappend dc_larr($i) $row_list
        }
        # save dc curve
        set dc_comments_arr($i) "This is a test table representing a distribution curve (dc)"
        set dc_name_arr($i) "dc-[ad_generate_random_string] [ad_generate_random_string]"
        set dc_title_arr($i) [string totitle $dc_name_arr($i)]
        set type_guess [acc_fin::pretti_type_flag $dc_larr($i) ]
        if { $type_guess ne "dc" } {
            ns_log Notice "acc_fin::pretti_example_maker type should be 'dc'. Instead type_guess '$type_guess'"
        }
#        ns_log Notice "acc_fin::pretti_example_maker.289 dc saving dc_larr($i): $dc_larr($i)"
        set dc_table_id_arr($i) [qss_table_create $dc_larr($i) $dc_name_arr($i) $dc_title_arr($i) $dc_comments_arr($i) "" $type_guess $package_id $user_id]
        
    }
    

    # p3
    ns_log Notice "acc_fin::pretti_example_maker.294 p3 start"
    set p3_larr [list ]
    set param_arr(p3_cols) [expr { int( [util::random] * ( $param_arr(p3_cols_max) - $param_arr(p3_cols_min) + .99 ) ) + $param_arr(p3_cols_min) } ]
    # required: type
    set title_list $p31_list
    set cols_diff [expr { $param_arr(p3_cols) -  [llength $title_list] } ]
    if { $cols_diff > 0 } {
        # Try to make some sane choices by choosing groups of titles with consistency
        # sane groupings of titles:
        if { $cols_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend title_list time_est_short time_est_median time_est_long
            incr cols_diff -3
        }
        if { $cols_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend title_list cost_est_low cost_est_median cost_est_high 
            incr cols_diff -3
        }
        # ungrouped ones can include partial groupings:
        # max_concurrent max_overlap_pct
        # time_dist_curve_name time_dist_curve_tid 
        # name description
        # cost_dist_curve_name cost_dist_curve_tid 
        # time_est_short time_est_median time_est_long
        # cost_est_low cost_est_median cost_est_high 

        # dependent_tasks
        # dependent_types --not implemented

        set ungrouped_list $p30_list
        foreach title $title_list {
            # remove existing title from ungrouped_list
            set title_idx [lsearch -exact $ungrouped_list $title]
            if { $title_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.327: title '$title' not found in p30 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p3_cols) - llength $title_list
        while { $cols_diff > 0 && $ungrouped_len > 0} {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [util::random] * $ungrouped_len ) } ]
            lappend title_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
            incr cols_diff -1
        }
    }
    set title_list [acc_fin::shuffle_list $title_list]
    lappend p3_larr $title_list
    set p2_cols_list [list ]
    set param_arr(p3_types) [expr { int( [util::random] * ( $param_arr(p3_types_max) - $param_arr(p3_types_min) + .99 ) ) + $param_arr(p3_types_min) } ]
    ns_log Notice "acc_fin::pretti_example_maker.357: title_list '$title_list'"
    for { set i 0} {$i < $param_arr(p3_types)} {incr i} {
        # new row
        set row_list [list ]
        foreach title $title_list {
            switch -exact $title {
                time_est_short  {
                    set row_arr($title) [expr { int( [util::random] * 256. + 5. ) / 24. } ]
                }
                time_est_median {
                    set row_arr($title) [expr { int( [util::random] * 256. + 10. ) / 12. } ]
                }
                max_run_time -
                time_est_long   { 
                    set row_arr($title) [expr { int( [util::random] * 256. + 20. ) / 6. } ]
                    # a random amount, assume hours for a task for example
                }
                cost_est_low    {
                    set row_arr($title) [expr { int( [util::random] * 100. + 90. ) / 100. } ]
                }
                cost_est_median {
                    set row_arr($title) [expr { int( [util::random] * 200. + 180. ) / 100. } ]
                }
                cost_est_high   {
                    set row_arr($title) [expr { int( [util::random] * 400. + 360. ) / 100. } ]
                    # these could be usd or btc for example
                }
                max_tasks_per_run  -
                max_concurrent {
                    set row_arr($title) [expr { int( [util::random] * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( [util::random] * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [util::random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_name_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [util::random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_table_id_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                name        -
                description {
                    set row_arr($title) [ad_generate_random_string]
                }
                type {
                    set row_arr($title) [ad_generate_random_string]
                    # add to a list for referencing in p2 form for later
                    lappend p2_cols_list $row_arr($title)

                }
                dependent_tasks -
                dependent_types {
                    set row_arr($title) ""
                }
                default {
                    ns_log Notice "acc_fin::pretti_example_maker.394: no switch option for '$title'"
                }
            }
            if { [info exists row_arr($title) ] } {
                lappend row_list $row_arr($title)
                array unset row_arr
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.396: no switch option for '$title'"
                lappend row_list ""
            }
        }
        # add row
        lappend p3_larr $row_list
    }
    # save p3 curve
    set p3_comments "This is a test table of PRETTI activity types (p3)"
    set p3_name "p3-[ad_generate_random_string] [ad_generate_random_string]"
    set p3_title [string totitle ${p3_name}]
    set type_guess [acc_fin::pretti_type_flag $p3_larr ]
    if { $type_guess ne "p3" } {
        ns_log Notice "acc_fin::pretti_example_maker type should be 'p3'. Instead type_guess '$type_guess'"
    }

    set p3_table_id [qss_table_create $p3_larr ${p3_name} ${p3_title} $p3_comments "" $type_guess $package_id $user_id ]

    # p2
    ns_log Notice "acc_fin::pretti_example_maker.419 p2 start"
    set p2_larr [list ]
    set param_arr(p2_cols) [expr { int( [util::random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]
    # required: type
    set title_list $p21_list
    set cols_diff [expr { $param_arr(p2_cols) -  [llength $title_list] } ]
#    ns_log Notice "acc_fin::pretti_example_maker.434 cols_diff $cols_diff param_arr(p2_cols) '$param_arr(p2_cols)' title_list $title_list"
    if { $cols_diff > 0 } {
        # Try to make some sane choices by choosing groups of titles with consistency
        # sane groupings of titles:
        if { $cols_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend title_list time_est_short time_est_median time_est_long
            incr cols_diff -3
        }
        if { $cols_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend title_list cost_est_low cost_est_median cost_est_high 
            incr cols_diff -3
        }
#        ns_log Notice "acc_fin::pretti_example_maker.448 cols_diff $cols_diff title_list $title_list"
        # ungrouped ones can include partial groupings:
        # max_concurrent max_overlap_pct
        # time_dist_curve_name time_dist_curve_tid 
        # name description
        # cost_dist_curve_name cost_dist_curve_tid 
        # time_est_short time_est_median time_est_long
        # cost_est_low cost_est_median cost_est_high 

        # dependent_tasks
        # dependent_types --not implemented

        set ungrouped_list $p20_list
#        ns_log Notice "acc_fin::pretti_example_maker.430: ungrouped_list $ungrouped_list"
        foreach title $title_list {
            # remove existing title from ungrouped_list
            set title_idx [lsearch -exact $ungrouped_list $title]
            if { $title_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $title_idx $title_idx]
#                ns_log Notice "acc_fin::pretti_example_maker.432: title_idx $title_idx"
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.435: title '$title' not found in p20 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set cols_diff expr $param_arr(p2_cols) - llength $title_list
#        ns_log Notice "acc_fin::pretti_example_maker.480: ungrouped_len $ungrouped_len cols_diff $cols_diff"
        while { $cols_diff > 0 && $ungrouped_len > 0 } {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [util::random] * $ungrouped_len ) } ]
            lappend title_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
            incr cols_diff -1
#            ns_log Notice "acc_fin::pretti_example_maker.481: ungrouped_len $ungrouped_len rand_idx $rand_idx cols_diff $cols_diff"
        }
#        ns_log Notice "acc_fin::pretti_example_maker.489"
    }
#    ns_log Notice "acc_fin::pretti_example_maker.490"
    set title_list [acc_fin::shuffle_list $title_list]
    lappend p2_larr $title_list
    set p2_cols_len [llength $p2_cols_list]
    set param_arr(p2_cols) [expr { int( [util::random] * ( $param_arr(p2_cols_max) - $param_arr(p2_cols_min) + .99 ) ) + $param_arr(p2_cols_min) } ]
    set p3_to_p2_count_ratio [expr { $param_arr(p2_cols) / $p2_cols_len } ]
    set p2_act_list [list ]
#    ns_log Notice "acc_fin::pretti_example_maker.495: p2_cols_len $p2_cols_len p3_to_p2_count_ratio $p3_to_p2_count_ratio param_arr(p2_cols) title_list '$title_list'"
    for { set i 0} {$i < $param_arr(p2_cols)} {incr i} {
        # new row
#        ns_log Notice "acc_fin::pretti_example_maker.497: i $i"
        set row_list [list ]
        foreach title $title_list {
            switch -exact $title {
                time_est_short  {
                    set row_arr($title) [expr { int( [util::random] * 256. + 5. ) / 24. } ]
                }
                time_est_median {
                    set row_arr($title) [expr { int( [util::random] * 256. + 10. ) / 12. } ]
                }
                time_est_long   { 
                    # a random amount, assume hours for a task for example
                    set row_arr($title) [expr { int( [util::random] * 256. + 20. ) / 6. } ]
                }
                cost_est_low    {
                    set row_arr($title) [expr { int( [util::random] * 100. + 90. ) / 100. } ]
                }
                cost_est_median {
                    set row_arr($title) [expr { int( [util::random] * 200. + 180. ) / 100. } ]
                }
                cost_est_high   {
                    # these could be usd or btc for example
                    set row_arr($title) [expr { int( [util::random] * 400. + 360. ) / 100. } ]
                }
                max_concurrent {
                    set row_arr($title) [expr { int( [util::random] * 12 ) + 1 } ]
                }
                max_overlap_pct {
                    set row_arr($title) [expr { int( [util::random] * 1000. ) / 1000. } ]
                }
                cost_dist_curve_name -
                time_dist_curve_name {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [util::random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_name_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                cost_dist_curve_tid -
                time_dist_curve_tid {
                    if { $param_arr(dc_count) > 0 } {
                        set x [expr { int( [util::random] * $param_arr(dc_count) * .9 ) } ]
                        set row_arr($title) $dc_table_id_arr($x)
                    } else {
                        set row_arr($title) ""
                    }
                }
                activity_ref {
                    set row_arr($title) [ad_generate_random_string]
                    lappend p2_act_list $row_arr($title)
                }
                name        -
                description {
                    set row_arr($title) [ad_generate_random_string]
                }
                aid_type {
                    set x [expr { int( [util::random] * $p2_cols_len * 2. ) } ]
                    if { $x < $p2_cols_len } {
                        set row_arr($title) [lindex $p2_cols_list $x]
                    } else {
                        set row_arr($title) ""
                    }
                }
                dependent_tasks {
                    set row_arr($title) ""
                    set count [expr { int( pow( [util::random] * 2.2 , [util::random] * 3.5 ) ) } ]
                    set ii 1
                    set delim ""
                    while { $ii < $count } {
                        set x [expr { int( [util::random] * $i ) } ]
                        append row_arr($title) $delim
                        append row_arr($title) [lindex $p2_act_list $x]
                        incr ii
                        set delim " "
                    }
                }
                cost_probability_point -
                time_probability_point {
                    set row_arr($title) ""
                }
                default {
                    ns_log Notice "acc_fin::pretti_example_maker.520: shouldn't happen. no switch option for '$title'"
                }
            }
            if { [info exists row_arr($title) ] } {
                lappend row_list $row_arr($title)
                array unset row_arr
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.530: no switch option for '$title'"
                lappend row_list ""
            }

        }
        # add row
        lappend p2_larr $row_list
    }
    # save p2 curve
    set p2_comments "This is a test table of PRETTI activity table (p2)"
    set p2_name "p2-[ad_generate_random_string] [ad_generate_random_string]"
    set p2_title [string totitle ${p2_name}]
    set type_guess [acc_fin::pretti_type_flag $p2_larr ]
    if { $type_guess ne "p2" } {
        ns_log Notice "acc_fin::pretti_example_maker type should be 'p2'. Instead type_guess '$type_guess'"
    }

    set p2_table_id [qss_table_create $p2_larr ${p2_name} ${p2_title} $p2_comments "" $type_guess $package_id $user_id ]

    # p1
    ns_log Notice "acc_fin::pretti_example_maker.560 p1 start"
    # activity_table_tid 
    # activity_table_name task_types_tid 
    # task_types_name 
    # time_dist_curve_name time_dist_curve_tid 
    # cost_dist_curve_name cost_dist_curve_tid 
    # time_est_short time_est_median time_est_long 
    # time_probability_point 
    # cost_est_low cost_est_median cost_est_high 
    # cost_probability_point 
    # db_format (1 or 0) saves p5 report table if db_format ne ""
   
    set p1_larr [list ]
    set param_arr(p1_vals) [expr { int( [util::random] * ( $param_arr(p1_vals_max) - $param_arr(p1_vals_min) + .99 ) ) + $param_arr(p1_vals_min) } ]
    # required: name value
    set title_list [list name value]
    lappend p1_larr $title_list
        # p1: activity_table_tid 
        # activity_table_name task_types_tid task_types_name time_dist_curve_name time_dist_curve_tid cost_dist_curve_name cost_dist_curve_tid time_est_short time_est_median time_est_long time_probability_point cost_est_low cost_est_median cost_est_high cost_probability_point db_format
    set vals_list $p11_list
    set vals_diff [expr { $param_arr(p1_vals) -  [llength $p11_list] } ]
    if { $vals_diff > 0 } {
        # Try to make some sane choices by choosing groups of names with consistency
        # sane groupings of names:
        if { $vals_diff > 3 } {
            # time_est_short time_est_median time_est_long
            lappend vals_list time_est_short time_est_median time_est_long
            incr vals_diff -3
        }
        if { $vals_diff > 3 } {
            # cost_est_low cost_est_median cost_est_high 
            lappend vals_list cost_est_low cost_est_median cost_est_high 
            incr vals_diff -3
        }
        # ungrouped ones can include partial groupings:
        # task_types_tid task_types_name
        # time_dist_curve_name time_dist_curve_tid 
        # cost_dist_curve_name cost_dist_curve_tid 
        # db_format
        # cost_probability_point
        # time_probability_point

        # why not these: ?? max_concurrent max_overlap_pct
        # currently defaults are unlimited and 100% overlapp

        set ungrouped_list $p10_list
        foreach value $vals_list {
            # remove existing name from ungrouped_list
            set val_idx [lsearch -exact $ungrouped_list $value]
            if { $val_idx > -1 } {
                set ungrouped_list [lreplace $ungrouped_list $val_idx $val_idx]
            } else {
                ns_log Notice "acc_fin::pretti_example_maker.573: value '$value' not found in p10 title list '${ungrouped_list}'"
            }
        }
        set ungrouped_len [llength $ungrouped_list]
        # set vals_diff expr $param_arr(p1_vals) - llength $title_list
        while { $vals_diff > 0 && $ungrouped_len > 0 } {
            # Select a random column to add to title_list
            set rand_idx [expr { int( [util::random] * $ungrouped_len ) } ]
            lappend vals_list [lindex $ungrouped_list $rand_idx]
            set ungrouped_list [lreplace $ungrouped_list $rand_idx $rand_idx]
            set ungrouped_len [llength $ungrouped_list]
#            ns_log Notice "acc_fin::pretti_example_maker.618: ungrouped_len $ungrouped_len rand_idx $rand_idx vals_diff $vals_diff"
            incr vals_diff -1
        }
    }
    set vals_list [acc_fin::shuffle_list $vals_list]
    set p1_types_len [llength $vals_list]
#    ns_log Notice "acc_fin::pretti_example_maker.662: vals_list '$vals_list'"
    
    foreach name $vals_list {
        set row_list [list ]
        switch -exact $name {
            time_est_short  {
                set row_arr($title) [expr { int( [util::random] * 256. + 5. ) / 24. } ]
            }
            time_est_median {
                set row_arr($title) [expr { int( [util::random] * 256. + 10. ) / 12. } ]
            }
            time_est_long   { 
                # a random amount, assume hours for a task for example
                set row_arr($title) [expr { int( [util::random] * 256. + 20. ) / 6. } ]
            }
            cost_est_low    {
                set row_arr($title) [expr { int( [util::random] * 100. + 90. ) / 100. } ]
            }
            cost_est_median {
                set row_arr($title) [expr { int( [util::random] * 200. + 180. ) / 100. } ]
            }
            cost_est_high   {
                # these could be usd or btc for example
                set row_arr($title) [expr { int( [util::random] * 400. + 360. ) / 100. } ]
            }
            cost_dist_curve_name -
            time_dist_curve_name {
                if { $param_arr(dc_count) > -1 } {
                    set x [expr { int( [util::random] * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_name_arr($x)
                } else {
                    set row_arr($title) ""
                }
            }
            cost_dist_curve_tid -
            time_dist_curve_tid {
                if { $param_arr(dc_count) > 0 } {
                    set x [expr { int( [util::random] * $param_arr(dc_count) ) } ]
                    set row_arr($title) $dc_table_id_arr($x)
                } else {
                    set row_arr($title) ""
                }
            }
            task_types_tid {
                set row_arr($title) $p3_table_id
            }
            task_types_name {
                set row_arr($title) $p3_name
            }
            activity_table_tid {
                set row_arr($title) $p2_table_id
            }
            activity_table_name {
                set row_arr($title) $p2_name
            }
            db_format   -
            name        -
            description {
                set row_arr($title) [ad_generate_random_string]
            }
            max_concurrent {
                set row_arr($title) [expr { int( [util::random] * 12 ) } ]
            }
            max_overlap_pct         -
            cost_probability_point -
            time_probability_point {
                # round off to nearest percent ( 0.01 )
                set row_arr($title) [expr { int( [util::random] * 100. ) / 100. } ]
            }
        }
        if { [info exists row_arr($title) ] } {
            lappend row_list $name $row_arr($title)
            array unset row_arr
            # add row to p1 table
            lappend p1_larr $row_list
        } else {
            ns_log Notice "acc_fin::pretti_example_maker.673: no switch option for '$title'"
        }
    }
    # save p1 table
    set p1_comments "This is a test table of PRETTI scenario table (p1)"
    set p1_name "p1-[ad_generate_random_string] [ad_generate_random_string]"
    set p1_title [string totitle ${p1_name}]
    set type_guess [acc_fin::pretti_type_flag $p1_larr ]
    if { $type_guess ne "p1" } {
        ns_log Notice "acc_fin::pretti_example_maker.671 type should be 'p1'. Instead type_guess '$type_guess'"
    }

    set p1_table_id [qss_table_create $p1_larr ${p1_name} ${p1_title} $p1_comments "" $type_guess $package_id $user_id ]
    # create a most simple test case using same data
    set p1b_lists [list [list name value] [list activity_table_tid ${p2_table_id}] ]
    set p1b_comments "This is a minimum test of PRETTI scenario table (p1)"
    set p1b_name "p1-minimum [ad_generate_random_string]"
    set p1b_title [string totitle ${p1b_name}]

    set type_guess [acc_fin::pretti_type_flag $p1b_lists ]
    if { $type_guess ne "p1" } {
        ns_log Notice "acc_fin::pretti_example_maker.683 type should be 'p1'. Instead type_guess '$type_guess'"
    }
    set p1b_table_id [qss_table_create $p1b_lists ${p1b_name} ${p1b_title} $p1b_comments "" $type_guess $package_id $user_id ]
    # check that tables saved without error.
    set status 1
    foreach {name dc_table_id} [array get dc_table_id_arr] {
        if { $dc_table_id eq 0 } {
            set status 0
            ns_log Notice "acc_fin::pretti_example_maker.690 dc_table_id for $name is '${dc_table_id}' instead of > 0."
        }
    }
    if { $p1b_table_id eq 0 || $p1_table_id eq 0 || $p2_table_id eq 0 || $p3_table_id eq 0 } {
        set status 0
        ns_log Notice "acc_fin::pretti_example_maker.695 all s/b > 0: p1b_table_id '$p1b_table_id' p1_table_id '$p1_table_id' p2_table_id '$p2_table_id' p3_table_id '$p3_table_id'"
    }
    if { $status } {
        set status $p1_table_id
    }
    return $status
}
