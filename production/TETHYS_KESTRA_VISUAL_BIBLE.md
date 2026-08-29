# Tethys / Kestra Visual Bible

## Purpose
This is the visual contract for Vertical Slice 2.0 and the later Godot/Blender authored-art pass. It prevents visual drift while the browser prototype remains procedural.

## Core art direction
Pale Signal should feel like practical field science colliding with an ancient inhabited landscape. Avoid glossy generic sci-fi, neon cyberpunk density, fantasy ornament, and clean theme-park futurism.

The visual language is:
- wet, mineral, wind-worn and functional;
- civic infrastructure built to survive water and weather;
- muted natural surfaces with restrained warm Talari materials;
- pale cyan/green technical emission used sparingly for active systems;
- the Pale Signal itself is visually abnormal because it is too coherent, too regular and too clean compared with the world.

## Tethys palette and materials
### Wilderness
- peat/wet soil: very dark brown-green, low specular except fresh water films;
- reed flats: desaturated olive/grey-green with small warm seed accents;
- exposed mineral shelves: cool grey, chalk green and iron-brown inclusions;
- standing water: dark reflective surfaces, never tropical blue;
- storm conditions: lower saturation, stronger cool atmospheric scattering and streaking rain.

### Material behavior
- roughness dominates most ground and civic surfaces;
- metal appears as repaired fittings, fasteners and machinery rather than broad decorative panels;
- emissive strips identify function, route or active civic systems and should not become general decoration;
- repeated contact surfaces show polish/wear while structural material remains weathered.

## Kestra silhouette
Kestra is a basin settlement shaped by flood management rather than a skyline-first city.

Primary silhouette hierarchy:
1. floodwalls, causeways and retained water establish the horizontal city;
2. civic tower/beacon gives one readable long-range vertical landmark;
3. terrace homes step with the basin rather than flattening it;
4. ferry/repair and market structures form low functional clusters;
5. landing approach lighting creates a legible flight corridor without turning the settlement into an airport runway field.

## Talari visual direction
Talari should read as residents with occupations and social context, not alien mascots.

Prototype silhouette targets:
- upright humanoid proportion with slightly narrow torso and practical layered clothing;
- muted cloth/mineral colors with limited individual variation;
- accessories communicate job or daily role: satchel, maintenance harness, civic mantle, tool carrier;
- facial/technical light accents remain subtle and never replace readable body language.

Production target:
- authored character mesh with at least three clothing/body variants from a shared rig;
- locomotion, idle, look-at, work, conversation and reaction animation sets;
- no exaggerated cartoon motion unless a specific cultural gesture requires it.

## Wildlife visual direction
Flat Grazers should visually belong to wet reed basins:
- broad low center of mass;
- muted hides that break up against peat/reeds;
- head/neck motion carries alertness more than dramatic full-body animation;
- retreat is readable but not predator-prey panic by default;
- animation speed and density reduce on mobile before clarity is reduced.

## Ship / EVA relationship
The player equipment is more manufactured and geometrically precise than Tethys, but still field-used rather than showroom-clean.

- ship exterior: practical panels, service seams, landing hardware and heat/wear zones;
- cockpit: dark functional surfaces, bright information only where operationally required;
- EVA: restrained head/camera cadence, readable tool/interaction response, no excessive bob;
- landing: contact, dust/water response, suspension/settle and audio communicate mass.

## Pale Signal visual grammar
The Signal is not purple magic fog or random glitch noise.

Use:
- concentric/coherent geometry;
- narrow-band pale emission;
- repeating phase relationships;
- local environmental motion that becomes unnaturally synchronized;
- subtle camera/fog interference that respects reduced-motion settings.

Escalation order:
1. barely visible coherence;
2. repeated spatial rhythm;
3. environmental response;
4. archaeology reconstruction resonance;
5. flight-scale coherence near affected regions.

## Lighting
- Tethys daylight is broad, humid and diffused;
- Kestra active civic lights are route/function markers, not decorative bloom fields;
- interiors/vestibules use warmer practical light to contrast wet exterior conditions;
- storm lighting lowers contrast at distance while preserving immediate interaction readability;
- Pale Signal effects may locally violate normal light rhythm but should remain restrained.

## UI relationship
HUD must not compete with the environment.
- contextual information appears only when useful;
- mobile prioritizes legibility and large touch targets;
- discovery presentation is short and centered but never blocks control;
- scanner confidence communicates uncertainty without creating a permanent opaque overlay.

## Production acceptance targets
An authored replacement asset must improve at least one of silhouette, material credibility, animation readability, storytelling, or performance. It should not be imported merely because it is more detailed.

For every hero asset, capture:
- distant silhouette;
- gameplay-range screenshot;
- material close-up;
- mobile screenshot;
- performance cost;
- license/provenance entry if external.

The browser procedural build is allowed to approximate this bible. The Godot/Blender production pass is where the final authored fidelity is expected.