#  RecipEase - A project created for the Fetch iOS Coding Challenge

## Description

This repository contains my implementation for the Fetch iOS Coding Challenge: Recipease, a recipes app that fetches dessert recipes from the TheMealDB API, and uses ChatGPT to generate short, informational descriptions of each dessert! 

### Setup (Important)
On line 11 of APIManager.swift is the following line:

`let OPEN_AI_API_KEY = "ENTER_OPEN_AI_API_KEY_HERE"`

Please paste the provided API key here.

### Basic features
1. HomeViewController.swift defines the home screen, which fetches all meals in the category "Desserts" and displays them in a list, alphabetically sorted by name.
2. A cache for downloaded images, in ImageCache.swift, that caches images to NSCache so they can be reused. The images are lazily downloaded only when the user scrolls through the table.
3. A details page, in DetailViewController.swift, which calls the lookup meal endpoint (www.themealdb.com/api/json/v1/1/lookup.php?i=ID). It pulls the ingredients, instructions and measures and displays them in an aesthetic page sheet.
4. Model classes, Dessert and DessertDetails, which use Codable to parse the JSON responses into Swift objects.

### ChatGPT integration
I've integrated OpenAI's ChatGPT, a generative language model that can create human-like text from a prompt. I provided the following prompt, replacing the list of desserts with the dessert names from the API.

```
Write me two-line appealing descriptions of the following food items. The descriptions must be short as they will be used as a preview for the food item in a recipe app. Your descriptions for each food item should strictly be in the following format: "1) Name of food item exactly as given in the prompt: Description of food item that is generated as output". Follow the above format for each food item, but put each food item and its description on a separate line.  Here are the food items that you need to generate descriptions for as per the form given in quotes above:

1) Dessert Name 1
2) Dessert Name 2
3) Dessert Name 3
4) Dessert Name 4
5) Dessert Name 5
6) Dessert Name 6
7) Dessert Name 7
8) Dessert Name 8
```

I chose to split the list of desserts into groups of 8. This is because requesting a single output creates repetitive outputs for the dessert list (since ChatGPT does not know what kind of output it previously generated without it being in the same context). Requesting the entire list of desserts at once would generate even higher quality output, but the response time is very slow (40 - 50 seconds). For 8, it is 5 - 7 seconds.

The ChatGPT API is called before the app opens the home screen. The progress is shown on a loading screen and the home screen opened when the generated responses for all desserts have been received.

### Other features
I also included a search feature for the home screen, which I felt was important for a list with a large number of items.
