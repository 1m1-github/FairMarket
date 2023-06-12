// go run utils/run.go 

package main

import (
	"crypto/sha512"
	"encoding/base32"
	"encoding/base64"
	"encoding/binary"
	"fmt"
)

func main() {
	calc_bid_id(
		"HQMMGGF3KJRPTEZV6GKGT6PNQJBZWUBIQMHG4XBVGBIV2E2V4LWOFHVEAA",
		"5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU",
		10458941,
		1,
		"q1",
	)

	// byte_array_to_b64([]byte{0x3c, 0x18, 0xc3, 0x18, 0xbb})

	calc_create_bid_note(
			"HQMMGGF3KJRPTEZV6GKGT6PNQJBZWUBIQMHG4XBVGBIV2E2V4LWOFHVEAA",
			"5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU",
			10458941,
			1,
			"q1",
		)
}

func calc_create_bid_note(A, B string, curreny_id, curreny_amount int, data string) []byte {
	B_bytes_with_checksum, _ := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(B)
	B_bytes := B_bytes_with_checksum[:32]

	bid_id_bytes := calc_bid_id_bytes(A, B, curreny_id, curreny_amount, data)

	dot := []byte(".")

	data_bytes := []byte(data)

	note_bytes := append(B_bytes, dot...)
	note_bytes = append(note_bytes, bid_id_bytes[:]...)
	note_bytes = append(note_bytes, dot...)
	note_bytes = append(note_bytes, data_bytes...)

	fmt.Println(len(note_bytes))
	fmt.Println(note_bytes)
	fmt.Println(base64.StdEncoding.EncodeToString(note_bytes))

	return note_bytes
}

func byte_array_to_b64(bytes []byte) {
	a := base64.StdEncoding.EncodeToString(bytes)
	fmt.Println(a)
}

func calc_bid_id(A, B string, curreny_id, curreny_amount int, data string) string {
	bid_id_bytes := calc_bid_id_bytes(A, B, curreny_id, curreny_amount, data)
	bid_id_b64 := base64.StdEncoding.EncodeToString(bid_id_bytes[:])
	fmt.Println(len(bid_id_bytes))
	fmt.Println(bid_id_bytes)
	fmt.Println(bid_id_b64)
	return bid_id_b64
}

func calc_bid_id_bytes(A, B string, curreny_id, curreny_amount int, data string) [32]byte {
	// address to []byte
	A_bytes_with_checksum, _ := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(A)
	A_bytes := A_bytes_with_checksum[:32]
	// fmt.Println(A_bytes)
	// fmt.Println(base64.StdEncoding.EncodeToString(a))

	B_bytes_with_checksum, _ := base32.StdEncoding.WithPadding(base32.NoPadding).DecodeString(B)
	// // b := []byte("5B3SUGACYLICWU3DHXYCS45NDNEFZCZM4MCKCKQA3DLGKZEOFQR74HLGEU")
	b := B_bytes_with_checksum[:32]
	// fmt.Println(b)
	// fmt.Println(base64.StdEncoding.EncodeToString(b))

	// // // int to []byte
	currency_id_bytes := make([]byte, 8)
	binary.BigEndian.PutUint64(currency_id_bytes, uint64(curreny_id))
	// fmt.Println(currency_id_bytes)
	// fmt.Println(base64.StdEncoding.EncodeToString(currency_id))

	currency_amount_bytes := make([]byte, 8)
	binary.BigEndian.PutUint64(currency_amount_bytes, uint64(curreny_amount))
	// fmt.Println(currency_amount_bytes)
	// fmt.Println(base64.StdEncoding.EncodeToString(currency_amount))

	// note_bytes := []byte(data)
	// fmt.Println(note_bytes)
	// // fmt.Println(base64.StdEncoding.DecodeString("aGVsbG8gd29ybGQ="))
	// fmt.Println(base64.StdEncoding.EncodeToString(note_bytes))

	bid_id_prehash := append(A_bytes, b...)
	bid_id_prehash = append(bid_id_prehash, currency_id_bytes...)
	bid_id_prehash = append(bid_id_prehash, currency_amount_bytes...)
	bid_id_prehash = append(bid_id_prehash, data...)
	// fmt.Println(bid_id_prehash)
	// fmt.Println(base64.StdEncoding.EncodeToString(bid_id_prehash))

	bid_id_bytes := sha512.Sum512_256(bid_id_prehash)
	// fmt.Println(bid_id_bytes)

	return bid_id_bytes
}