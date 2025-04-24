;; Lab Verification Contract
;; This contract validates accredited testing facilities

(define-data-var admin principal tx-sender)

;; Map of accredited labs
(define-map accredited-labs
  { lab-id: (string-ascii 20) }
  {
    name: (string-ascii 100),
    accreditation-date: uint,
    accreditation-expiry: uint,
    status: (string-ascii 10)
  }
)

;; Public function to register a new lab
(define-public (register-lab (lab-id (string-ascii 20)) (name (string-ascii 100)) (accreditation-expiry uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? accredited-labs { lab-id: lab-id }))) (err u100))
    (ok (map-set accredited-labs
      { lab-id: lab-id }
      {
        name: name,
        accreditation-date: block-height,
        accreditation-expiry: accreditation-expiry,
        status: "active"
      }
    ))
  )
)

;; Public function to verify if a lab is accredited
(define-read-only (is-lab-accredited (lab-id (string-ascii 20)))
  (match (map-get? accredited-labs { lab-id: lab-id })
    lab-data (and
              (is-eq (get status lab-data) "active")
              (< block-height (get accreditation-expiry lab-data)))
    false
  )
)

;; Public function to revoke lab accreditation
(define-public (revoke-accreditation (lab-id (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? accredited-labs { lab-id: lab-id })
      lab-data (ok (map-set accredited-labs
                  { lab-id: lab-id }
                  (merge lab-data { status: "revoked" })))
      (err u404)
    )
  )
)

;; Public function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
