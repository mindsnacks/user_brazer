## Set up

- Clone somewhere on your computer (`git clone git@github.com:mindsnacks/user_brazer.git`)
- Run `gem install httparty`

## Attribute Exporter: Running a file

- Set up your explore. You will need to have a column for Users -> Elevate User ID and a column for whatever attribute you want to export. Here's an example: https://elevatelabs.looker.com/explore/elevate_datawarehouse/users?qid=5dyJ80uCaAY3u39ySXjCHl
- Go to the gear next to the Run button, then Download. Make sure to download All Results (in the Limit section).
- Go into the downloaded file and remove the first column of row numbers
- The new first column should have the header 'user_id'
- The second column should have the header 'looker_export.<NAME_OF_YOUR_ATTRIBUTE>' where <NAME_OF_YOUR_ATTRIBUTE> is the name you want for the new attribute.
- Run the file by running `ruby attribute_exporter.rb` in the user_brazer folder
- QA by taking various user IDs from the CSV and checking if the attribute shows up on the Braze user records. If this is your first time running this, try doing a test run by using a dummy attribute (e.g. `looker_export.test_on_2018_02_09`)—we can always blacklist old/test attributes, so it's better to try it out first instead of potentially messing up the attribute you want to target.

## Frankenbrazer: Importing new emails that aren't Elevate or Balance users 
(creates 'non-users' in the Non-User app group)

- Make sure you have the APPBOY_NON_USER_APP_GROUP_ID. Go into Braze, go to 'Elevate pre-users' and then go to Developer Console. Take the Identifier from the API key section: https://cl.ly/f1e05718ce80 (this allows you to make requests to that App Group using Frankenbrazer). From the command line, run `echo 'export APPBOY_NON_USER_APP_GROUP_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"' >> ~/.bash_profile` where the XXXX is the API key you pull from the Developer Console. Reload your console by running `exec $SHELL -l` or by opening a new Terminal tab.
- Put all emails in the emails_to_import.csv file. Don't include a header row.
- Run frankenbrazer: `ruby frankenbrazer.rb`. Let Jesse G know if something breaks with a screenshot.
- All users will have an attribute that's a timestamp of their import (e.g. `import_cohort_2018-09-20_04:32:33`). You can use this to filter and send emails.
- Check that the users were uploaded properly by looking for emails in your CSV and checking that the attribute is there. You may have multiple user_id records for the same email address (this system creates user_ids based on the timestamp) - this is OK since Braze will handle unsubscribes on an email level, not a user_id level, and you should use the attributes created during import to segment/send off emails.