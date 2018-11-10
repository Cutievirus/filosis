/*Fix cropping*/
Phaser.Component.Crop.prototype.updateCrop = function () {
    if (!this.cropRect) return;

    var oldX = this.texture.crop.x;
    var oldY = this.texture.crop.y;
    var oldW = this.texture.crop.width;
    var oldH = this.texture.crop.height;

    this._crop = Phaser.Rectangle.clone(this.cropRect, this._crop);
    this._crop.x += this._frame.x;
    this._crop.y += this._frame.y;

    //var cx = Math.max(this._frame.x, this._crop.x);
    //var cy = Math.max(this._frame.y, this._crop.y);
    //var cw = Math.min(this._frame.right, this._crop.right) - cx;
    //var ch = Math.min(this._frame.bottom, this._crop.bottom) - cy;
    var cx=this._crop.x
    var cy=this._crop.y
    var cw=this._crop.right - cx
    var ch=this._crop.bottom - cy

    this.texture.crop.x = cx;
    this.texture.crop.y = cy;
    this.texture.crop.width = cw;
    this.texture.crop.height = ch;

    this.texture.frame.width = Math.min(cw, this.cropRect.width);
    this.texture.frame.height = Math.min(ch, this.cropRect.height);

    this.texture.width = this.texture.frame.width;
    this.texture.height = this.texture.frame.height;

    this.texture._updateUvs();

    if (this.tint !== 0xffffff && (oldX !== cx || oldY !== cy || oldW !== cw || oldH !== ch))
    {
        this.texture.requiresReTint = true;
    }

};
Phaser.Sprite.prototype.updateCrop=Phaser.Image.prototype.updateCrop=Phaser.Component.Crop.prototype.updateCrop;

/* Adds support for astral planes */
Phaser.BitmapText.prototype.updateText = function () {

    var data = this._data.font;

    if (!data) return;

    var text = this.text;
    var scale = this._fontSize / data.size;
    var lines = [];

    var y = 0;

    this.textWidth = 0;

    do
    {
        var line = this.scanLine(data, scale, text);

        line.y = y;

        lines.push(line);

        if (line.width > this.textWidth)
        {
            this.textWidth = line.width;
        }

        y += (data.lineHeight * scale);

        text = text.substr(line.text.length + 1);
        
    } while (line.end === false);

    this.textHeight = y;

    var t = 0;
    var align = 0;
    var ax = this.textWidth * this.anchor.x;
    var ay = this.textHeight * this.anchor.y;

    for (var i = 0; i < lines.length; i++)
    {
        var line = lines[i];

        if (this._align === 'right')
        {
            align = this.textWidth - line.width;
        }
        else if (this._align === 'center')
        {
            align = (this.textWidth - line.width) / 2;
        }
        // EDIT
        textarray = (Array.from ? Array.from(line.text) : line.text)
        for (var c = 0; c < textarray.length; c++)
        {
            var charCode = textarray[c].codePointAt(0);
            var charData = data.chars[charCode];

            if (charData === undefined)
            {
                charCode = 32;
                charData = data.chars[charCode];
            }

            var g = this._glyphs[t];

            if (g)
            {
                //  Sprite already exists in the glyphs pool, so we'll reuse it for this letter
                g.texture = charData.texture;
            }
            else
            {
                //  We need a new sprite as the pool is empty or exhausted
                g = new PIXI.Sprite(charData.texture);
                g.name = line.text[c];
                this._glyphs.push(g);
            }

            g.position.x = (line.chars[c] + align) - ax;
            g.position.y = (line.y + (charData.yOffset * scale)) - ay;

            g.scale.set(scale);
            g.tint = this.tint;
            g.texture.requiresReTint = true;

            if (!g.parent)
            {
                this.addChild(g);
            }

            t++;
        }
    }

    //  Remove unnecessary children
    //  This moves them from the display list (children array) but retains them in the _glyphs pool
    for (i = t; i < this._glyphs.length; i++)
    {
        this.removeChild(this._glyphs[i]);
    }

};

Phaser.BitmapText.prototype.scanLine = function (data, scale, text) {

    var x = 0;
    var w = 0;
    var lastSpace = -1;
    var wrappedWidth = 0;
    var prevCharCode = null;
    var maxWidth = (this._maxWidth > 0) ? this._maxWidth : null;
    var chars = [];

    //  Let's scan the text and work out if any of the lines are > maxWidth
    var textarray=(Array.from ? Array.from(text) : text);
    for (var i = 0; i < textarray.length; i++)
    {
        var end = (i === textarray.length - 1) ? true : false;

        if (/(?:\r\n|\r|\n)/.test(textarray[i]))
        {
            if (typeof textarray==='string') return { width: w, text: text.substr(0, i), end: end, chars: chars };
            textarray.length=i
            return { width: w, text: textarray.join(''), end: end, chars: chars };
        }
        else
        {
            var charCode = textarray[i].codePointAt(0);
            var charData = data.chars[charCode];

            var c = 0;

            //  If the character data isn't found in the data array 
            //  then we replace it with a blank space
            if (charData === undefined)
            {
                charCode = 32;
                charData = data.chars[charCode];
            }

            //  Adjust for kerning from previous character to this one
            var kerning = (prevCharCode && charData.kerning[prevCharCode]) ? charData.kerning[prevCharCode] : 0;

            //  Record the last space in the string and the current width
            if (/(\s)/.test(textarray[i]))
            {
                lastSpace = i;
                wrappedWidth = w;
            }
            
            //  What will the line width be if we add this character to it?
            c = (kerning + charData.texture.width + charData.xOffset) * scale;

            //  Do we need to line-wrap?
            if (maxWidth && ((w + c) >= maxWidth) && lastSpace > -1)
            {
                //  The last space was at "lastSpace" which was "i - lastSpace" characters ago
                //return { width: wrappedWidth || w, text: text.substr(0, i - (i - lastSpace)), end: end, chars: chars };
                textarray.length=i
                return { width: wrappedWidth || w, text: textarray.join(''), end: end, chars: chars };
            }
            else
            {
                w += (charData.xAdvance + kerning) * scale;

                chars.push(x + (charData.xOffset + kerning) * scale);

                x += (charData.xAdvance + kerning) * scale;

                prevCharCode = charCode;
            }
        }
    }

    return { width: w, text: text, end: end, chars: chars };

};