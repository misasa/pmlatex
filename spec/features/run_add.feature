Feature: run add

  	As a user
	I want to add a file
	So that I can get success message

	Scenario: add file
		Given I am not yet playing
#		Given I have set up medusa
		Given I have a empty directory "tmp"
		Given I have a file "tmp/template.tex"
		Given I have a file "tmp/template.pdf"		
		When I start pmlatex with "add tmp/template.tex"
#		Then I start pmlatex with "commit tmp/template.tex"