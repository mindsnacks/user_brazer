## Set up

- Clone somewhere on your computer (`git clone git@github.com:mindsnacks/user_brazer.git`)
- Run `gem install httparty`

## Running a file

- Set up your explore. You will need to have a column for Users -> Elevate User ID and a column for whatever attribute you want to export. Here's an example: https://elevatelabs.looker.com/explore/elevate_datawarehouse/users?qid=5dyJ80uCaAY3u39ySXjCHl
- Go to the gear next to the Run button, then Download. Make sure to download All Results (in the Limit section).
- Go into the downloaded file and remove the first column of row numbers
- The new first column should have the header 'user_id'
- The second column should have the header 'looker_export.<NAME_OF_YOUR_ATTRIBUTE>' where <NAME_OF_YOUR_ATTRIBUTE> is the name you want for the new attribute.
- Run the file by running `ruby attribute_exporter.rb` in the user_brazer folder
- QA by taking various user IDs from the CSV and checking if the attribute shows up on the Braze user records. If this is your first time running this, try doing a test run by using a dummy attribute (e.g. `looker_export.test_on_2018_02_09`)—we can always blacklist old/test attributes, so it's better to try it out first instead of potentially messing up the attribute you want to target.