# Canonical::Property

The `Canonical::Property` model represents a property that can be owned or belong to the player in Skyrim. There are 10 properties in Skyrim, assuming the Hearthfire add-on is present:

* The Arch-Mage's Quarters (College of Winterhold)
* Breezehome (Whiterun)
* Vlindrel Hall (Markarth)
* Proudspire Manor (Solitude)
* Honeyside (Riften)
* Hjerim (Windhelm)
* Severin Manor (Raven Rock)
* Lakeview Manor (Falkreath)
* Heljarchen Hall (The Pale)
* Windstad Manor (Hjaalmarch)

Of these, the last three are [homesteads](https://elderscrolls.fandom.com/wiki/Homestead_(Hearthfire)) that the user can build in the course of the game.

## Attributes

One of the common characteristics of most properties in Skyrim (other than Severin Manor and the Arch-Mage's Quarters) is that the user gets to choose which items to purchase or build for them. As such, most of the fields on the `Canonical::Property` model are booleans indicating whether particular features are possible for a given property.

## Homesteads

The three homesteads (Lakeview Manor, Heljarchen Hall and Windstad Manor) are set apart by the fact that the player starts with them as land and must build the houses on them. Each homestead has a small house, main hall and cellar that can be built. Additionally, the homesteads each have three wings. Each wing has three possible rooms that can be built there, as shown in the table below (the three rooms for each wing are mutually exclusive, but this logic is handled in the non-canonical model). The homesteads are provided by the [Hearthfire](https://elderscrolls.fandom.com/wiki/The_Elder_Scrolls_V:_Hearthfire) DLC.

| **Location**   | **Tower**           | **Room with Outdoor Patio** | **Downstairs Room** |
| -------------- | ------------------- | --------------------------- | ------------------- |
| **West Wing**  | Enchanter's Tower   | Bedrooms                    | Greenhouse          |
| **North Wing** | Alchemy Laboratory* | Storage Room                | Trophy Room         |
| **East Wing**  | Library             | Armory                      | Kitchen             |

Each homestead also has a cellar that can be built; this is where the forge will be located, should the player choose to build one, as well as shrines to the Nine Divines.

Each homestead also has one outdoor element unique to it:

* Apiary (Lakeview Manor)
* Grain Mill (Heljarchen Hall)
* Fish Hatchery (Windstad Manor)

\* The "Alchemy Laboratory" here refers to what is referred to as the "alchemy tower" in the database, to differentiate it from an actual alchemy lab, which is available in homestead properties regardless of the presence of this room.

## Properties as Locations

Properties are different from other types of "items" in SIM in two ways:

1. Each property is also a location (often with sublocations)
2. Properties are an organising element in SIM - users will be able to associate inventory and wish lists with specific properties

The implications of both of these factors are being uncovered as we continue building out the back end.
