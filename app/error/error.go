package error

type PError struct {
	Status  int    `xml:"status" json:"status"`
	Message string `xml:"message" json:"message"`
}
