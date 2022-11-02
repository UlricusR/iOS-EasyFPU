# EasyFPU for iOS

![EasyFPU app icon](assets/images/pizza_small.png){ align=left }

An iOS app - mainly for Type 1 Diabetes patients - to ease the calculation of carbs, fat-protein-units (FPUs) (aka extended carbs, e-carbs or fake carbs) and their matching absorption time - synchronized across all your iOS devices via iCloud (optional).

## Disclaimer

!!! warning

    I need and want to emphasize that the use of this app is on your own risk!

The Fat-Protein-Units and absorption time calculated by this app are based on the recommendations of nutrition scientific articles, see list of links on this page. The app calculates FPUs by taking the total calories of a food item and subtracting the calories based on carbs (4 kcal/g). The difference represents the calories based on fat and proteins. For more details, please refer to the chapter on the absorption scheme.

!!! warning

    What you will do with this calculation, is completely up to you - you act on your own risk! Although I have thoroughly tested the calculation algorithm (and use it for a pump based insulin therapy in my own family), I refuse to guarantee its correctness.

Just a few hints from our personal experience:

- If you're looping, the loop loves to know if there are further carbs to be expected over time. It will then adjust its BG projection and - if activated by you - increase amount the and/or number of auto-boluses.
- If your auto-bolus settings limit the bolus amount for safety reasons, you may experience a high proposed manual bolus (e.g. 1.5 units at a BG of 180 mg/dl). Be careful before you really apply this, better reduce to half the amount in the beginning.
- In any case: Closely watch your BG when first starting to work with FPUs.
