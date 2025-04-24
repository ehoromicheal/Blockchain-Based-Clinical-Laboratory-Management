;; Testing Protocol Contract
;; Manages approved methodologies

(define-data-var admin principal tx-sender)

;; Map of approved testing protocols
(define-map testing-protocols
  { protocol-id: (string-ascii 20) }
  {
    name: (string-ascii 100),
    version: (string-ascii 10),
    approval-date: uint,
    status: (string-ascii 10),
    test-type: (string-ascii 30)
  }
)

;; Map of protocol requirements
(define-map protocol-requirements
  { protocol-id: (string-ascii 20) }
  {
    equipment: (list 10 (string-ascii 30)),
    certifications: (list 5 (string-ascii 30)),
    controls: (list 5 (string-ascii 30))
  }
)

;; Public function to register a new protocol
(define-public (register-protocol
                (protocol-id (string-ascii 20))
                (name (string-ascii 100))
                (version (string-ascii 10))
                (test-type (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (not (is-some (map-get? testing-protocols { protocol-id: protocol-id }))) (err u100))

    (map-set testing-protocols
      { protocol-id: protocol-id }
      {
        name: name,
        version: version,
        approval-date: block-height,
        status: "active",
        test-type: test-type
      }
    )

    (ok true)
  )
)

;; Public function to set protocol requirements
(define-public (set-protocol-requirements
                (protocol-id (string-ascii 20))
                (equipment (list 10 (string-ascii 30)))
                (certifications (list 5 (string-ascii 30)))
                (controls (list 5 (string-ascii 30))))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? testing-protocols { protocol-id: protocol-id })) (err u404))

    (map-set protocol-requirements
      { protocol-id: protocol-id }
      {
        equipment: equipment,
        certifications: certifications,
        controls: controls
      }
    )

    (ok true)
  )
)

;; Public function to deprecate a protocol
(define-public (deprecate-protocol (protocol-id (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))

    (match (map-get? testing-protocols { protocol-id: protocol-id })
      protocol-data (ok (map-set testing-protocols
                        { protocol-id: protocol-id }
                        (merge protocol-data { status: "deprecated" })))
      (err u404)
    )
  )
)

;; Read-only function to check if a protocol is active
(define-read-only (is-protocol-active (protocol-id (string-ascii 20)))
  (match (map-get? testing-protocols { protocol-id: protocol-id })
    protocol-data (is-eq (get status protocol-data) "active")
    false
  )
)

;; Read-only function to get protocol details
(define-read-only (get-protocol-details (protocol-id (string-ascii 20)))
  (map-get? testing-protocols { protocol-id: protocol-id })
)

;; Read-only function to get protocol requirements
(define-read-only (get-protocol-requirements (protocol-id (string-ascii 20)))
  (map-get? protocol-requirements { protocol-id: protocol-id })
)
