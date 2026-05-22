# Nucleol_in

* **Developed by:** Thomas 
* **Developed for:** Shannon
* **Team:** Prochiantz
* **Date:** May 2026
* **Software:** Fiji


### Images description

3D images taken with x40 objective on a zeiss confocal microscope.

3 channels:
  1. Nucleolin
  2. GFP motoneurons(not used)
  3. Dapi nucleus

### Macro description

* Segment Nucleolin channel on sum slices Z projection 
* Segment Nucleus in the DAPI channel on a max intensity Z projection
* multiply both segmented channel to ensure we get only nucleus with Nucleolin
* Perform a "find focus slices" for each filtered nucleus on the original Nucleolin channel
* find Nucleol and keep the biggest for each nucleus
* For each nucleus compute (on the average intensity z projection of the focus slices) :

  * Area 

  * Nucleoplasm Mean intensity 
  * Nucleoplasm Integrated Density / Integrated Density Normalise

  * Nucleol Circularity and Aspect Ratio
  * Nucleol Mean intensity 
  * Nucleol Integrated Density / Integrated Density Normalise



### Dependencies

* **Find Focus Slices** (installable via Update Sites)

### Version history

Version 1 released on May 19, 2026.

