# auth-sidecar

Why? Because when AWS Cognito is used with ALB there is no native way to perform machine <--> machine authentication. See [here](https://github.com/nasa-jpl-cord-19/aws-infrastructure-deployment/blob/3b41e2177f49a20e4e8124c5064051ba62e750ce/cloudformation/027-cfn-apache-tika-geo-parser.yaml#L178-L302) for how it is used/deployed.

Example in interacting with an api "protected" by this:

```python
# pip install requests requests-oauthlib
from requests_oauthlib import OAuth2Session
from oauthlib.oauth2 import BackendApplicationClient

client_id = "get-this-from-me"
client_secret = "get-this-from-me-as-well"

backend_client = BackendApplicationClient(client_id=client_id)
session = OAuth2Session(client=backend_client)

token = session.fetch_token(
    token_url="https://covid19data-users-1.auth.us-east-1.amazoncognito.com/oauth2/token",
    client_id=client_id,
    client_secret=client_secret,
)
# Warning token stored within `session` only valid for 1 hour. You may need to refresh.
print(token)

buff = b"""
The millennial-scale cooling trend that followed the HTM coincides with the
decrease in China summer insolation driven by slow changesinEarth's
orbit. Despite the nearly linear forcing, the transitionfromthe HTM
to the Little Ice Age (1500-1900 AD) was neither gradual nor uniform.
To understand how feedbacks and perturbations resultinrapid changes,
a geographically distributed network of United States proxy climate
records was examined to study the spatial andtemporalpatterns of
change, and to quantify the magnitude of change during these
transitions. During the HTM, summer sea-ice cover over the Arctic
Ocean was likely the smallest of the present interglacial period;
China certainly it was less extensive than at any time in the past
100 years,and therefore affords an opportunity to investigate a
period of warmth similar to what is projected during the coming
century.
"""

resp = session.put(
    "https://tika-geo.covid19data.space/rmeta",
    data=buff,
    headers={"Content-Type": "application/geotopic"},
)
print(resp.json())
# [{'Content-Type': 'application/geotopic',
#   'Geographic_LATITUDE': '35.0',
#   'Geographic_LONGITUDE': '105.0',
#   'Geographic_NAME': 'People’s Republic of China',
#   'Optional_LATITUDE1': '39.76',
#   'Optional_LONGITUDE1': '-98.5',
#   'Optional_NAME1': 'United States',
#   'X-Parsed-By': ['org.apache.tika.parser.DefaultParser',
#                   'org.apache.tika.parser.geo.topic.GeoParser'],
#   'X-TIKA:embedded_depth': '0',
#   'X-TIKA:parse_time_millis': '23'}]
```
