# Kew_POWO_data
Extract data on plant species distribution form  Kew Gardens' Plants of the World On-line using **_R_**

# Why?

Studies of the global distribution of plants require good data on the current distribtuion of plant species. It is particularly important to distiguish between the "natural" or native distirbution of a species, and the "unnatural", non-native distribution.

Kew Gardens maintains a database of plant species which includes information on the native and non-native distribution of those species. However, they do not provide an Applicaiont PRogramming Interface or API. The web serivce allows you to develop and applicaiton which can send well-strucutured queries to the server and receive formatted data in repsonse. Examples of this kind of serfvice in ecoinformatiocs are the Global Biodiversity Information Facility (GBIF) and the closely-linked Atlas of Living Australia (ALA). To find out more about this kind of service, I recommend the API documentation provided by ALA which is found [here](https://support.ala.org.au/support/solutions/articles/6000196777-ala-api-how-to-access-ala-web-services) with full service documentation [here](https://api.ala.org.au/).

Finally, the motivation for developing this script was to assist colleagues gather data on the native and non-native distribution of a list of plant species from the POWO website in an convenient and easily-repeated manner. 

# How?

When users access a web interface like the Kew POWO, information is gathered by a webform within the webpage supplying the user intereface to the data service. The calls to the web servcies which generate response pages are visible to technically skilled users. This supplied sufficient information to generate requests to the Kew web server _as though they had been entered by human user_.

> **That is, the script imitates EXACTLY what a live human user would do, and does not compromise or circumvent Kew Gardens web servce in anyway.**

Sending the proper request to the Kew Gardens web server returns a standard web page which is read and parsed by the script to extract useful data components.

# Constraints and limitations

The taxonomic names used by Kew Gardens does't always agree with other sources of plant names. This is not Kew Garden's "fault" but a commonly encountered problem in ecoinformatics. Taxonomists must make decisions about which species dpoefiniton to accpet and which name amongst competing candidate published names should be applied in a given situation. To allow others to make follow-up decisions, taxonomists and plant name authorities inlude lists of plant name they judge to be alternatives to their selected "accepted name". This list is referred to as a "synonymy", and if the name you accept is listed as a synonym, you can confidently associate the data supplied by that authority with your preferred name.

> This script does not deal with the issue of resolving synonyms. You will need to manually untangle any name not accepted by Kew Gasrdens when the script returns a message of "Name is not accepted by POWO". 

Information on synonymns is provided by Kew Gardens POWO webspages not parsed by the script, and from other name authorities such as GBIF, the International Plant Name Index, and for taxa present in Australia, ALA. The _R_-packages _rgibf_ and _galah_ provide tools to gather such information too.

# Suggested usage

The script is provided as an _R_ function which you can load and use as follows:

```
source("/pathename/to/Kew_POWO_distodata.R")

ans <- fetch_POWO_info("Eucalyptus saligna")

# Check for non-empty response
if ((ans$nativeCodes != "") & (ans$non_nativeCodes != ""))
{
  ## Code to process returned data...
}

```

Note that the script requires that the _R_-package _httr_ and its dependencies are available in your local _R_ installation.

Finally, the information returned is the three-letter acronym for a region listed inthe Taxonomic Database Working Group (TDWG) Level-3 names. A look-up table in CSV-format is included in this repository.


