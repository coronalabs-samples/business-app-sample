application = {
   content = {
      --
      -- width and height will be calcuated at about 160 points per inch
      --
      -- Adaptive is based on a 320 point content area and larger screens will have more screen space
      -- to use.
      scale = "adaptive",
      fps = 60,

      imageSuffix = {
         ["@2x"] = 1.5,
         ["@3x"] = 2.5,
         ["@4x"] = 3.1,
      },
   },
   notification = 
   {
      iphone =
      {
         types = { "badge", "sound", "alert" }
      },
      google =
      {
         projectNumber = "1234567890"
      },
   }
}