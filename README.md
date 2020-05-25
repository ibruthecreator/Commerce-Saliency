# Commerce Saliency
## Create quick promotional images for the products your selling

### Overview
An intuitive app that allows you to quickly take pictures of your products wherever you are, intelligently crop it using a ML saliency model, add text and then export.

If you're interested in how the server works, visit the [backend repo.](https://github.com/ibruthecreator/saliency-backend)

### Demo
![First demo](./demos/demo1.gif "First Demo")
![Second demo](./demos/demo2.gif "Second Demo")

### BASNet
The model this app is using (deployed to a backend server) is (BASNet)[https://github.com/NathanUA/BASNet]. 

### To-Do
- [ ] Fix framing bug when scaling (using pinch gesture) or editing the text of an already rotated UITextView
- [ ] Change the color wheel to look more like Snapchat's color selector (rod rather than a wheel)
- [ ] Add export options for messaging and other social media
- [ ] Allow users to adjust text alignment
- [ ] Allow users to adjust color of text
- [ ] *eventually* change to an offline local model rather than needing a cloud service 

