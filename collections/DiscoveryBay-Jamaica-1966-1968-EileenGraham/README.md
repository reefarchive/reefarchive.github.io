# Eileen Graham's Collection (Discovery Bay, Jamaica, 1966 to 1968)

Image-level metadata and photographs documenting coral reefs at Discovery Bay, Jamaica, between 1966 and 1968. This data package contains 1,447 still images and one metadata record per image. Photographs were captured by Eileen Graham, digitised by Kenneth Johnson, and processed by Lewis A. Jones.

- **DOI:** [https://doi.org/10.5281/zenodo.22663464](https://doi.org/10.5281/zenodo.22663464)
- **Version:** 1.0.1
- **Licence:** [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/legalcode)
- **Related project:** [Reef Archive](https://reefarchive.org)

## Contents

```
DiscoveryBay-Jamaica-1966-1968-EileenGraham/
├── README.md          This file
├── datapackage.json   Machine-readable description of the package and data dictionary
├── media.csv          Metadata table, one row per image (1,447 rows, 31 columns)
└── media/             Image files, named <fileName>.<extension> (e.g. IMG0001.png)
```

Each row in `media.csv` links to its image through `fileName`. The globally unique identifier for each image is `mediaID` (the `collectionID` plus `fileName`).

## Data dictionary

Every field in `media.csv` is defined in `datapackage.json`, including its type, definition, an example value and whether it is required. Key fields:

| Field | Description |
|---|---|
| `mediaID` | Unique identifier for the image (primary key) |
| `fileName` | Name of the image file, with extension |
| `year`, `month`, `day` | When the photograph was taken |
| `waterBody`, `island`, ..., `locality`  | Where the photograph was taken |
| `decimalLatitude`, `decimalLongitude` | Location in decimal degrees (EPSG:4326) |
| `georeferenceRemarks` | How the coordinates were determined and their precision |
| `mediaComments` | Notes on the image, including date uncertainty |

## Coverage

- **Time:** 1966 to 1968 (583 images from 1966, 627 from 1967, 237 from 1968)
- **Place:** Discovery Bay, Saint Ann Parish, Jamaica (Caribbean Sea, Greater Antilles); latitude 18.399 to 18.486, longitude -77.504 to -76.886
- **Sites:** 28 named localities; the most frequent are Buoy Upper Slope, Algal Plots and Pear Tree Bottom
- **Media type:** still images only

## Provenance and processing

- **Original material:** 35 mm negatives held in the archives of the Natural History Museum (NHM), London, UK.
- **Digitisation:** Scanned using an Epson Perfection V500 scanner.
- **Processing:** Metadata compiled by Eileen Graham with the support of Judy Lang from field notebooks and personal experience.
- **Original files:** Original scanned images available from the  NHM data portal [https://data.nhm.ac.uk/dataset/coral-reef-imagery-by-eileen-graham-of-jamaica-in-the-1960s](https://data.nhm.ac.uk/dataset/coral-reef-imagery-by-eileen-graham-of-jamaica-in-the-1960s).

## Known limitations

- **Dates:** 49 images have no month or day. Their year is inferred as 1966 from a possible range of 1966 to 1968, and `mediaComments` records this.
- **Coordinates are approximate.** For 1,429 images the coordinates were inferred from a site map and are precise to roughly 250 m. For 18 images the Discovery Bay Marine Laboratory was used as the point of reference. See `georeferenceRemarks` on each row.
- **Missing values:** `locality` is empty for 2 images. `habitat`, `stateProvince`, `minimumDepthInMetres` and `maximumDepthInMetres` are empty for all images (no values were recorded); the columns are kept so the table matches the data standard. No depth information is available.

## Licence and rights

The images and metadata are released under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/legalcode), which allows reuse, including commercial reuse, with attribution. Rights in the images are held by the Trustees of the Natural History Museum. Please cite the collection as below and credit Eileen Graham as the photographer.

## Citation

Johnson, K. and Jones, L.A. (2026) Eileen Graham Collection, Discovery Bay, Jamaica (1966 to 1968). [https://doi.org/10.5281/zenodo.22663465](https://doi.org/10.5281/zenodo.22663465).

## Contact and corrections

Questions, corrections, and additional information about the images (for example identifications of sites or dates) are welcome. Contact Lewis A. Jones ([lewisa.jones@outlook.com](mailto:lewisa.jones@outlook.com)) or Kenneth Johnson ([k.johnson@nhm.ac.uk](mailto:k.johnson@nhm.ac.uk)).

## Changelog

**1.0.1 (2026-09-29):**

  - Dropped file extension from `mediaID`
  - Refined location information (not coordinates)
  - Set collective DOI instead of version-specific

**1.0.0 (2026-09-20):** 

  - Initial release

## Acknowledgements

The data standard implemented in the [Reef Archive](https://www.reefarchive.org) is heavily influenced by both the [Darwin Core](https://dwc.tdwg.org) and [CamTrap DP](https://camtrap-dp.tdwg.org). We thank these working groups for leading the way.