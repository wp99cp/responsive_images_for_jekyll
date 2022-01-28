# Creates responsive and optimized images for Jekyll!

## Image Optimizing Pipeline

An automatic pipeline for image optimizing. This allows for the content creator to use images out of a
camara, those images are huge in filesize, e.g. around 2MB. The pipeline now automatically creates five images in
different size and optimizes them for file site. From our original image we get for example a 450x300px image with a
file size of 40kB.

The image optimizing pipeline is implemented in `pre-processor.rb` and `image-optimizer.rb`.

The first script converts the markdown image tag into a custom format, which is the used by the second script to
generate HTML code.

The pre-processor takes in markdown code and converts an image:

```markdown
![Image description used as subtitle and alt text.](assets/path/to/image.jpg)
```

to the custom liquid tag:

```markdown
{{% image assets/path/to/image.jpg :: Image description used as subtitle and alt text. :: Image description used as
subtitle and alt text. %}
```

Which then gets processed by the image optimizer into, the image-optimizer automatically creates all needed image files
and stores them in the `imgs` folder.

```html
<figure>
    <img src="/imgs/path/to/image.jpg_1800x1200.jpg" alt="Image description used as subtitle and alt text."
         srcset=" /imgs/path/to/image_1800x1200.jpg 1800w, /imgs/path/to/image_1200x800.jpg 1200w,
                               /imgs/path/to/image_1125x750.jpg 1125w,  /imgs/path/to/image_600x400.jpg 600w,
                               /imgs/path/to/image_450x300.jpg 450w ">
    <span> Image description used as subtitle and alt text. </span>
</figure>
```
