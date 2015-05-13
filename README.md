# Project-3
GROUP-4, Project-3 for SWEN30006
Group members:
Anu, Cristian, Liang, Purathani
We are doing a team project for software modeling and design class by using ruby on rails.

The aim of this project is to use your skills in downloading, parsing and regressing data to look for correlations
between different data sets use this information to provide a service that will perform hyperlocal weather
predictions.

2015-05-13
I added a scheduler named crono this afternoon. 
To use the scheduler, you can follow the 
guide: https://github.com/plashchynski/crono
or 
steps below:
1. Put scheduled code here: /weather/app/jobs
2. Then define schedule list here: /weather/config/cronotab.rb
3. Then use bundle exec crono -e development
4. Tasks run! Cheers~
