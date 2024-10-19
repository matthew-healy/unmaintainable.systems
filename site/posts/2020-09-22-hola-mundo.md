---
author: "matthew liam healy"
desc: "This is a description of a page"
image: "./images/waiheke-stony-batter.jpg"
keywords: "hello, announcement"
lang: "en"
title: "¡Another post!"
updated: "2020-09-23T12:00:00Z"
---

This is another example post.

<img
  alt="Grapevines among rolling hills leading to the sea"
  src="./images/waiheke-stony-batter.jpg"
  height="200"
/>

Some Haskell code!

```haskell
toSlug :: T.Text -> T.Text
toSlug =
  T.intercalate (T.singleton '-') . T.words . T.toLower . clean
```
