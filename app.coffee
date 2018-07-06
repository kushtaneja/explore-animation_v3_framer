Array::indexOf or= (item) ->
  for x, i in this
    return i if x is item
  return -1

data = JSON.parse Utils.domLoadDataSync "data/data.json"

gutter = 20
padding = 16
boxSize = (Screen.width-3*padding)/2
thumbSize = ((Screen.width)/3)*1
focusedBoxHeight = 124	
bucketThumbnailsContainerHeight = thumbSize + 2*padding
activeBucket = null
activeTag = null
maxNoOfVisibleTags = 5
tagSpacing = 10
switchVersion = false
visibleTags = []

makeBucketActive = (bucket) ->
	bucket.thumb.state = "active"
	bucket.label.state = "active"
	bucket.thumb.states.switchInstant "active"
	bucket.label.states.switchInstant "active"
	bucketThumbnailsContainer.backgroundColor = bucket.data.backgroundColor
	activeBucket = bucket
	newBucketIndex = bucketBoxes.indexOf(bucket)
	centerBucket = if newBucketIndex > 1 then bucketBoxes[newBucketIndex-1] 								else activeBucket
	activeIndex = bucketBoxes.indexOf(activeBucket)
	bucketThumbnailsContainer.scrollToLayer(centerBucket)
	for inActiveBucketBox, index in bucketBoxes
		if index != activeIndex
			inActiveBucketBox.thumb.states.switchInstant "default"
			inActiveBucketBox.thumb.state = "default"
			inActiveBucketBox.label.states.switchInstant "default"
			inActiveBucketBox.label.state = "default"
	for tagLayer in tagsContainer.content.children
		tagLayer.destroy()
	tags = []					
	for tagObject, tagIndex in bucket.data.tags
		tag = new Tag
			originX: 0
			y: 0, originY: 0
			opacity: 0.7
		
		tag.label.x = Align.left(1)
		tag.label.y = Align.center
		tag.label.text = "#" + tagObject.name
		tag.width = tag.label.width + 4
		sumOfWidths = 0
		for i in [0...tagIndex]
			sumOfWidths += tags[i].label.width + 4
		tag.x = tagIndex*(tagSpacing) + sumOfWidths
		if tagIndex == 0
			makeTagActive(tag)
			
		tags.push tag
	visibleTags = tags

makeTagActive = (tag)->
	if activeTag
		activeTag.backgroundColor = "#transparent"
		activeTag.label.color = "black"
		tag.opacity = 0.7
	tag.backgroundColor = "#E8E8E8"
	tag.label.color = "purple"
	tag.opacity = 1
	activeTag = tag
	tagsContainer.scrollToLayer(tag)

class BucketThumb extends Layer
	constructor: (@options={}) ->
		thumbSize = bucketThumbnailsContainer.height*2/3
		@options.height ?= thumbSize
		@options.width ?= (@options.height)*.7
		@options.backgroundColor ?= "rgba(255,255,255,0)"
			
		@label = new TextLayer
			fontSize: 16

		@thumb = new Layer
					
		super @options
		
		@thumb.parent = @
		@thumb.height = @options.height*0.7
		@thumb.width = @thumb.height
		@thumb.centerX()
		@thumb.state = "default"
		
		@label.parent = @
		@label.centerX()
		@label.textAlign = "center"
		@label.state = "default"
		@label.width = @options.width
		@label.autoHeight = yes
		@label.centerX()
		@label.color = "rgba(255,255,255,1)"
		@label.fontStyle = "bold"
		@label.opacity = 0.7
		@label.y = @thumb.y + @thumb.height + 0.05*@options.height
		
		@thumb.states = 
			active:
				opacity:1
			default:
				opacity: 0.5
		@label.states = 
			active:
				fontWeight: 600
				opacity: 1
			default:
				fontWeight: 400
				opacity: 0.6
						
		@onClick ->
			if @.thumb.state == "default"
				makeBucketActive(@)

bucketThumbnailsContainer = new ScrollComponent
	width: Screen.width, height: if switchVersion then Screen.height*0.3 else thumbSize*1.3
	backgroundColor: "black"
bucketThumbnailsContainer.parent = screen_1
bucketThumbnailsContainer.scrollVertical = false
bucketThumbnailsContainer.mouseWheelEnabled = true
bucketThumbnailsContainer.content.clip = false
bucketThumbnailsContainer.directionLock = true
bucketThumbnailsContainer.state = "default"
bucketThumbnailsContainer.contentInset = 
		right: padding
		left: padding
		top: 2.4*padding

bucketThumbnailsContainer.states =
	default:
		height: if switchVersion then Screen.height*0.3 else thumbSize*1.3
		parent: screen_1
		scrollVertical: false
	collapsed:
		height: if switchVersion then Screen.height*0.15 else thumbSize*0.7
		animationOptions:
			curve: Bezier.easeIn
			time: 0.1
				
tagsContainer = new ScrollComponent
	width: Screen.width, height: bucketThumbnailsContainerHeight*0.2 + padding
	backgroundColor: "transparent"
	parent: if switchVersion then bucketThumbnailsContainer else screen_1
	scrollVertical: false
	mouseWheelEnabled: true
	clip: false
	directionLock: true
	state: "default"
	y: if switchVersion then Align.bottom else bucketThumbnailsContainer.screenFrame.y + bucketThumbnailsContainer.screenFrame.height + padding/3
	contentInset:
		right: padding
		left: padding
		top: (bucketThumbnailsContainerHeight*0.2 + padding)*0.1

tagsContainer.content.backgroundColor = "transparent"
tagsContainer.states =
	collapsed:
			y: bucketThumbnailsContainer.screenFrame.y + bucketThumbnailsContainer.screenFrame.height + padding/3
	animationOptions:
		curve: Bezier.easeIn
		time: 0.1

class Tag extends Layer
	constructor: (@options={}) ->
		@options.borderRadius = 8
		@options.backgroundColor = "transparent"
		@options.width ?= (Screen.width - padding)/maxNoOfVisibleTags - tagSpacing
		@options.parent = tagsContainer.content
		@options.height = tagsContainer.height*0.8
		@options.clip = true
		
		@label = new TextLayer
			autoSize: true
			textAlign: Align.center
			
		super @options
		
		@label.parent = @	
		@label.center()
		@label.backgroundColor = "transparent"
		@label.fontSize = 14
		@label.color = "black"
		@label.fontWeight = "bold"
		@label.text = ""
		@label.textAlign = "center"
		
		@onClick ->
			makeTagActive(@)

bucketBoxes = []		
for bucketObject, index in data.buckets
	bucketBoxThumb = new BucketThumb
		x: index*(.8*padding+thumbSize*0.8), y: Align.top
		parent: bucketThumbnailsContainer.content
		
	ratio = (bucketObject.image.width/bucketObject.image.height)
	bucketBoxThumb.thumb.image = bucketObject.image	
	bucketBoxThumb.thumb.style = backgroundSize: "contain"
	bucketBoxThumb.label.text = bucketObject.name
	bucketBoxThumb.data = bucketObject
	bucketBoxThumb.thumb.state = "default"
	bucketBoxThumb.state = "default"
	if index == 1
		bucketThumbnailsContainer.backgroundColor = bucketObject.backgroundColor	
	bucketBoxes.push(bucketBoxThumb)	

defaultBucket = bucketBoxes[1]
makeBucketActive(defaultBucket)


contentView = new ScrollComponent
	parent: screen_1
	y: tagsContainer.y + tagsContainer.height
	width: Screen.width, height: Screen.height
	scrollHorizontal: false

tagFeed = new Layer
	parent: contentView.content
	y: Align.top
	width: contentView.width
	height: (7454/1071)*contentView.width

tagFeed.image = "images/feed.jpg"

collapsed = false
contentView.onScrollStart ->	
	if contentView.direction == "down"
		if !collapsed 
			collapsed = true
			bucketThumbnailsContainer.states.switchInstant "collapsed"
			
			tagsContainer.y = bucketThumbnailsContainer.screenFrame.y + bucketThumbnailsContainer.screenFrame.height + padding/3
			tagsContainer.height = bucketThumbnailsContainerHeight*0.2 + padding
			contentView.y = tagsContainer.y + tagsContainer.height
		
			for bucketBox, index in bucketBoxes
				newHeight = bucketThumbnailsContainer.height*2/3
				bucketBox.height = newHeight
				bucketBox.thumb.width = newHeight*0.7
				bucketBox.thumb.height = newHeight*0.7
				bucketBox.label.visible = false
				bucketBox.x = index*(.4*padding+newHeight*0.8)
			
			for tag, tagIndex in visibleTags
				tag.label.fontSize = 12
				tag.label.x = Align.left(1)
				tag.label.y = Align.center
				tag.width = tag.label.width + 4
				tag.height = tagsContainer.height*0.8
				sumOfWidths = 0
				for i in [0...tagIndex]
					sumOfWidths += visibleTags[i].label.width + 4
				tag.x = tagIndex*(tagSpacing) + sumOfWidths
				
			bucketThumbnailsContainer.contentInset = 
				right: 0
				left: padding
				top: 2.4*padding
			
contentView.onScrollEnd ->
	if contentView.direction == "up"
		if collapsed
			collapsed = false
			bucketThumbnailsContainer.states.switchInstant "default"
			
			tagsContainer.y = bucketThumbnailsContainer.screenFrame.y + bucketThumbnailsContainer.screenFrame.height + padding/3
			tagsContainer.height = bucketThumbnailsContainerHeight*0.2 + padding
			contentView.y = tagsContainer.y + tagsContainer.height
		
			for bucketBox, index in bucketBoxes
				newHeight = bucketThumbnailsContainer.height*2/3
				bucketBox.height = newHeight
				bucketBox.thumb.width = newHeight*0.7
				bucketBox.thumb.height = newHeight*0.7
				bucketBox.label.visible = true
				bucketBox.x = index*(.4*padding+newHeight*0.8)
			
			for tag, tagIndex in visibleTags
				tag.label.fontSize = 12
				tag.label.x = Align.left(1)
				tag.label.y = Align.center
				tag.width = tag.label.width + 4
				tag.height = tagsContainer.height*0.8
				sumOfWidths = 0
				for i in [0...tagIndex]
					sumOfWidths += visibleTags[i].label.width + 4
				tag.x = tagIndex*(tagSpacing) + sumOfWidths
				
			bucketThumbnailsContainer.contentInset = 
				right: 0
				left: padding
				top: 2.4*padding
			