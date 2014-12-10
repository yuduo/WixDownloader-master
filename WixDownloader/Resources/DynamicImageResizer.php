<?php
/**
 * Author: Adam Kazimierczak
 * Link: http://kazymjir.com/blog/image-resizing-php-class/
 * License: GNU GPL v2
 *
 * Takes image filename and desired resolution from URL, resizes and returns it with proper headers to browser
 *
 * This class is used for dynamic image resizing.
 * It takes filename, extension and desired resolution from URL using GET method.
 * On successful resize it returns the result to a browser with proper headers (like <em>Content-Type</em>, etc).
 * On failure it throws an Exception with message about the error.
 *
 * GET params are:
 * - <strong>file</strong> - image filename without extension ('cat' is good, 'cat.jpg' is wrong)
 * - <strong>ext</strong> - image extension (JPG, GIF, PNG)
 * - <strong>size</strong> - desired target size (800x600, 355x245, 121x54, etc)
 *
 * Example usage:
 * <strong>PHP CODE</strong>
 * <code>
 * require_once('DynamicImageResizer.php');
 * $resizer = new DynamicImageResizer('./images/', $_GET);
 * $resizer->output();
 * </code>
 *
 * <strong>HTML CODE</strong>
 *
 <samp>* <img src="image.php?file=cutecat&ext=JPG&size=800x600" alt="My cute cat" />
 *</samp>
 *
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details:
 * http://www.gnu.org/licenses/gpl.html
 */

class DynamicImageResizer {
    
    private $acceptedExtensions = array('jpg','jpeg','png','gif');
    
    private $image; // image resource (created by GD library)
    private $base; // base directory with images
    private $file; // path to image
    private $size; // image target size
    private $type; // image type
    private $quality; // image quality
    
    /**
     * Construtor
     * @param string $dir Base directory for images
     * @param array $params Params assoc array, must contain 'file', optionally 'size' and 'quality'
     * @param int $quality Quality as a numeric value in range 0-100, where 0 is the worst and 100 is the best
     */
    function __construct($dir, array $params, $quality = 90) {
        self::setBaseDir($dir);
        self::setParams($params);
        self::setQuality($quality);
    }
    
    /**
     * Output the image to a browser
     */
    function output() {
        self::processImage();
        header('Content-Type: ' . image_type_to_mime_type($this->type));
        flush();
        imagejpeg($this->image, NULL, $this->quality);
    }
    
    /**
     * Set base directory for images
     * @param string $dir Base directory
     * @throws Exception
     */
    private function setBaseDir($dir) {
        if(!is_dir($dir)) {
            throw new Exception('Wrong base directory');
        }
        $this->base = $dir;
    }
    
    /**
     * Set image parameters: filename and target size
     * @param array $params Image params as assoc array, must contain: 'file' and optionally 'size'
     * @throws Exception
     */
    private function setParams(array $params) {
        /* Check if there are all params in the array */
        if(empty($params['file'])) {
            throw new Exception('Image parameters are incomplete');
        }
        
        /* set filename */
        // Occurence of double dots in the filename can be a security violation (ie. '../../../etc/nuclearRocketsCodes')
        if(!false == strpos($params['file'], '..')) {
            throw new Exception('Wrong filename');
        }
        $temp = $this->base . '/' . $params['file'];
        if(!file_exists($temp)) {
            throw new Exception('Image file not exists');
        }
        $this->file = $temp;
        
        /* set target size */
        if(!empty($params['size'])) {
            $size = explode('x',$params['size']);
            if(!is_numeric($size[0]) || !is_numeric($size[1])) {
                throw new Exception('Image target size is invalid');
            }
            $this->size = array('width' => $size[0], 'height' => $size[1]);
        }
        
        /* image type */
        // since php_exif.dll is often not enabled on Windows machines, we must use an alternative method
        $temp = getimagesize($this->file);
        $this->type = $temp[2];
    }
    
    /**
     * Loads image file
     */
    private function loadImage() {
        switch($this->type) {
            case IMAGETYPE_JPEG:
                $this->image = imagecreatefromjpeg($this->file);
                break;
            case IMAGETYPE_GIF:
                $this->image = imagecreatefromgif($this->file);
                break;
            case IMAGETYPE_PNG:
                $this->image = imagecreatefrompng($this->file);
                break;
        }
    }
    
    /**
     * Set quality of image (sent to browser)
     * @param int $quality Numeric value in 0-100 range, where 0 is the worst and 100 is the best
     * @throws Exception
     */
    private function setQuality($quality) {
        if(!is_numeric($quality)) {
            throw new Exception('Quality mu be a numeric value in 0-100 range');
        }
        $this->quality = $quality;
    }
    
    /**
     * Load and (if needed) resize the image
     */
    private function processImage() {
        self::loadImage($this->file);
        if(!empty($this->size)) {
            $currentWidth = imagesx($this->image);
            $currentHeight = imagesy($this->image);
            $targetWidth = $this->size['width'];
            $targetHeight = $this->size['height'];
            $temp = imagecreatetruecolor($targetWidth, $targetHeight);
            
            imagecopyresampled($temp, $this->image, 0, 0, 0, 0, $targetWidth, $targetHeight, $currentWidth, $currentHeight);
            $this->image = $temp;
        }
    }
}

?>