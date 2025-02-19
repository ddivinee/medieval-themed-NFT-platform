;; CryptoKnights Gaming Platform Smart Contract
;; Handles medieval-themed NFT ownership and trading functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-invalid-price (err u104))
(define-constant max-knight-rank u100)
(define-constant max-honor-points u10000)
(define-constant max-metadata-length u256)
(define-constant max-batch-size u10)  ;; Limit batch operations to prevent potential gas issues

;; Data Variables
(define-map knights 
    { knight-id: uint }
    { owner: principal, metadata-uri: (string-utf8 256), tradeable: bool })

(define-map knight-prices
    { knight-id: uint }
    { price: uint })

(define-map knight-stats
    { player: principal }
    { honor-points: uint, rank: uint })

(define-map tavern-listings
    { knight-id: uint }
    { seller: principal, price: uint, listed-at: uint })

;; Knight Counter
(define-data-var knight-counter uint u0)

;; Helper Functions

;; Validate knight exists and return knight data
(define-private (get-knight-checked (knight-id uint))
    (let ((knight (map-get? knights { knight-id: knight-id })))
        (asserts! (and 
                (is-some knight)
                (<= knight-id (var-get knight-counter)))
            err-not-found)
        (ok (unwrap-panic knight))))

;; Validate metadata URI length
(define-private (validate-metadata-uri (uri (string-utf8 256)))
    (let ((uri-length (len uri)))
        (and 
            (> uri-length u0)
            (<= uri-length max-metadata-length))))

;; Public Functions

;; Batch Mint new knights
(define-public (batch-mint-knights 
    (metadata-uris (list 10 (string-utf8 256))) 
    (tradeable-list (list 10 bool)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and 
            (> (len metadata-uris) u0)
            (<= (len metadata-uris) max-batch-size)
            (is-eq (len metadata-uris) (len tradeable-list))) 
            err-invalid-input)
        (let ((minted-knights 
            (map mint-single-knight 
                metadata-uris 
                tradeable-list)))
            (ok minted-knights))))

;; Helper function for batch minting
(define-private (mint-single-knight 
    (uri (string-utf8 256))
    (tradeable bool))
    (let 
        ((knight-id (+ (var-get knight-counter) u1)))
        (asserts! (validate-metadata-uri uri) err-invalid-input)
        (map-set knights
            { knight-id: knight-id }
            { owner: contract-owner,
              metadata-uri: uri,
              tradeable: tradeable })
        (var-set knight-counter knight-id)
        (ok knight-id)))

