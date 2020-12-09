# Make -B to make everything.

number != pwd | pcregrep -o1 ".*([0-9].*)"
course != pwd | pcregrep -o1 ".*phys([0-9]+)"
base_term != pwd | pcregrep -o1 "(\d{4}/(fall|winter|spring)\d{4})"
assignment := phys442_fall2020_problem_set_$(number)
stamp := "Question"
# note the following path to database which allows working on problem sets
# before the term in question:
database = ~/$(base_term)/d/physics_question_database
create_assignment = $(database)/create_assignment/development/create_assignment.py

$(assignment)_generated.pdf : $(assignment).tex \
                              $(database)/database/physics_questions.db
	rm -rf *generated.*
	git log --pretty=format:'last commit hash: %h  ' -n 1 > \
	  git_info_generated.txt
	git log --pretty=format:'last commit date: %aI' -n 1 >> \
	  git_info_generated.txt
	  echo "\n" >> git_info_generated.txt
	git status -s >> git_info_generated.txt
	python3 $(create_assignment) --no_solutions \
	  --database $(database) $(assignment).tex
	lualatex --shell-escape $(assignment)_generated
	lualatex --shell-escape -halt-on-error -interaction=batchmode $(assignment)_generated
	python3 $(create_assignment) --database $(database)\
           --stamp $(stamp) $(assignment).tex
	if [ -f $(assignment)_generated.pdf ]; \
	  then pdf2ps $(assignment)_generated.pdf ; fi
	if [ -f $(assignment)_solutions_generated.pdf ]; \
	  then pdf2ps $(assignment)_solutions_generated.pdf ; fi
	if [ -f \
            $(assignment)_solutions_partial_or_not_committed_generated.pdf ]; \
	  then pdf2ps \
            $(assignment)_solutions_partial_or_not_committed_generated.pdf ; fi
	if [ -f hints.tex ]; then \
	  lualatex --shell-escape -jobname $(assignment)_hints_generated \
                   hints.tex ; \
	  lualatex --shell-escape -jobname $(assignment)_hints_generated \
                   hints.tex ; fi 

