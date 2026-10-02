# SurveySolutionsAPIv2: Comprehensive API Access to Your Survey Solutions Server Using 'httr2'

A comprehensive suite of functions for interfacing with the Survey
Solutions APIs (<https://demo.mysurvey.solutions/apidocs/index.html> and
<https://docs.mysurvey.solutions/>). It supports all the current POST,
GET, and PATCH requests of the REST API and extends its capabilities by
integrating selected GraphQL API queries and mutations when REST API
equivalents are not available. Designed for ease of use, it includes
several convenience functions to streamline operations. The package
ensures that data retrieved from the API is automatically transformed
into a single, easy-to-use data frame or data table, optimizing it for
subsequent analysis and processing. Additionally, it is specifically
designed to facilitate seamless integration into R Shiny applications,
enhancing the interactive web application development experience. Built
on the robust 'httr2' package, this version supersedes the previous
'httr'-based implementation. Recognizing the needs of large-scale data
operations such as censuses, the package also incorporates features for
parallel processing, enhancing its efficiency and scalability.

## Author

**Maintainer**: Michael Wild <mwild@worldbank.org> \[copyright holder\]
