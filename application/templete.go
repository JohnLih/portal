package application

type Application struct {
	Id      string     `xml:"id,attr" json:"id,omitempty"`
	Filled  string     `xml:"filled,attr" json:"filled,omitempty"`
	Options []*Options `xml:"options,omitempty" json:"options,omitempty"`
	Actions *Actions   `xml:"actions,omitempty" json:"actions,omitempty"`
}

type Actions struct {
	Action []*Action `xml:"action,omitempty" json:"action,omitempty"`
}

type Action struct {
	Name   string  `xml:"name,attr" json:"name,omitempty"`
	Label  string  `xml:"label,attr" json:"label,omitempty"`
	Script *Script `xml:"script,omitempty" json:"script,omitempty"`
}

type Options struct {
	Id     string    `xml:"id,attr" json:"id,omitempty"`
	Name   string    `xml:"name,attr" json:"name,omitempty"`
	Info   string    `xml:"info,attr" json:"info,omitempty"`
	Option []*Option `xml:"option,omitempty" json:"option,omitepty"`
}

type Option struct {
	Id       string    `xml:"id,attr" json:"id,omitempty"`
	Type     string    `xml:"type,attr" json:"type,omitempty"`
	Name     string    `xml:"name,attr" json:"name,omitempty"`
	Required bool      `xml:"required,attr" json:"required"`
	Label    string    `xml:"label,attr" json:"label,omitempty"`
	Width    string    `xml:"width,attr" json:"width,omitempty"`
	Height   string    `xml:"height,attr" json:"height,omitempty"`
	Hidden   bool      `xml:"hidden,attr" json:"hidden,omitempty"`
	Default  string    `xml:"default,attr" json:"default,omitempty"`
	Script   *Script   `xml:"script,omitempty" json:"script,omitempty"`
	Option   []*Option `xml:"option,omitempty" json:"option,omitempty"`
	Text     string    `xml:"value,attr" json:"value,omitempty"`
}

type Script struct {
	Type string `xml:"type,attr" json:"type,omitempty"`
	Text string `xml:"value,attr" json:"value,omitempty"`
}
