periop
======

Perioperative Application


Periop
========================


The purpose of the application is to prepare a summary of a patient’s health based on information entered into the application.

The information in this summary comes from 

1. patient procedure information
2. patient assessment completed by the patient (the form that I want you to work on)
3. clinician assessment completed by the doctor.

All of the questions are defined in the OpenOffice spreadsheet

/spreadsheet/Question_properties_OO.ods

The answer to each question is linked to a “concept”.  Information about a concept can come from any of the forms and is included in the summary.

In the Questions tab of the spreadsheet are all of the questions.

Columns
* A: question order - the questions appear on a form according to the order in this spreadsheet - not sure if this number does anything
* B: cross check of concept only.
* C: Unique Question ID
* D: Concept that the question links to
* E: Question text
* F: Conditions for displaying the question.  This refers to the "concept" for questions asked earlier in the form.
* G: Input type refers to how the data is collected
** 	Statement - no input, puts a statement on the form
**	Start_section - used form marking the start of a section (currently concertina and only used on Clinician Assessment Form)
**	End_section - used form marking the end of a section
**	Free_text - text box
**	Text_box - larger text box
**	Date - datepicker 
**	OneOption - currently a dropdown but should be a radio button
**	Lookup_User_Anesthetist - looks up a list of users
**	ManyOptions - checkboxes
**	Number - not sure if this really is a type or if it is stored as text
* H: Option list for OneOption and ManyOptions (the options are shown in the Option_List tab)
* I: Length of text - I’m not sure if this is used or not
* J: Ask_details - if this is Y, it will ask for more details if the answer matches column K
* K: Condition to show “Please provide more information” box
* L: Mandatory question
* M: Validation_criteria is not really used except for the datepicker.  Past - the datepicker won’t allow dates in the future.  Future - datepicker won’t allow dates int he past.
* N: cross check on concept position
* O: Question used in patient assessment - this is the default form that appears for patients to fill in.  We have subsequently implemented patient assessments that depend on each doctor.  You can see mine in column T.  A few others are in column U, V, W, X
* Columns P, Q, R, S are forms that are used in other parts of the application.  
* P: Questions used in a Clinician Assessment - this form is used by the doctor and doesn’t face the patient.  This is the one that makes use of the section breaks above.
* Q: Each new “procedure” is entered as a new patient using this form
* R: This form is no longer used
* S: Quick note form




The view "assessments" determines how the questions are displayed.


Important tasks

1. Stop users from hitting enter and prematurely submitting the form
2. Radio buttons
3. Break the form up into sections to stop users taking the form out of order.  Age and gender a key inputs that determine much of the subsequent form and should be determined on the first page.  I can add a new section_break to the spreadsheet to help break up the forms.
4. Progress indicator
5. Mobile friendly










(c) 2012 - David Belavy with all rights reserved