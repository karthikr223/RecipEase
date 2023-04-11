#  Recipease - A project created for the Fetch iOS Coding Challenge

## Description

This repository contains my implementation for the Fetch iOS Coding Challenge: Recipease, a recipes app that fetches dessert recipes from the TheMealDB API, and uses ChatGPT to generate short, informational descriptions of each dessert! 

### Basic features
1. HomeViewController.swift defines the home screen, which fetches all meals in the category "Desserts" and displays them in a list, alphabetically sorted by name.
2. A cache for downloaded images, in ImageCache.swift, that caches images to NSCache so they can be reused. The images are lazily downloaded only when the user scrolls through the table.
3. A details page, in DetailViewController.swift, which calls the lookup meal endpoint (www.themealdb.com/api/json/v1/1/lookup.php?i=ID). It pulls the ingredients, instructions and measures and displays them in an aesthetic page sheet.
4. Model classes, Dessert and DessertDetails, which use Codable to parse the JSON responses into Swift objects.

### ChatGPT integration
I've also integrated OpenAI's ChatGPT, a generative language model that can create human-like text from a prompt. Here, I provided the name of the dessert and a few example descriptions, 

```
Write me two-line appealing descriptions of the following food items. The descriptions must be short as they will be used as a preview for the food item in a recipe app. Here are the food items:

Lemon Coconut Cake: Enjoy a flavor fusion of zesty lemon curd and sweet cream cheese, all sandwiched between layers of deliciously moist coconut cake - an irresistible treat for any special occasion!

Strawberry Rhubarb Upside Down Cake: Enjoy the sweet and tart combination of succulent strawberries and tangy rhubarb atop a deliciously moist cake, all finished off with a luxurious caramel sauce!

Kaiserschmarrn: This classic Austrian dish of torn pancakes is made extra special with plump raisins soaked in rum, and your choice of delicious fruits as a topping - irresistible for breakfast, lunch or dinner.

(INPUT_DESSERT_NAME):"
```

The ChatGPT API is called before the app opens the home screen. The progress is shown on a loading screen and the home screen opened when the generated responses for all desserts have been received.

### Other features
I also included a search feature for the home screen, which I felt was important for a list with a large number of items.
