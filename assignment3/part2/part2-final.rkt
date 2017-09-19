;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname part2-final) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Mikel Matticoli and Ankur Gupta
;; CS1102 HW 3 Part 2

;; ================
;; Data Defintions

(define-struct widget(name quantity time price parts))
;; a widget is a (make-widget String Natural Natural Number ListOfWidget)

#;
(define (fn-for-widget w)
  (... (widget-name w)
       (widget-quantity w)
       (widget-time w)
       (widget-price w)
       (fn-for-low
        (widget-parts w))))

;; Template rules used
;; Compound: 4 fields
;; Reference: (widget-parts w) is a (listof Widget)

;; (listof Widget) is a list of widgets

#;
(define (fn-for-low low)
  (cond [(empty? low) ...]
        [else 
         (... fn-for-widget (first low)
              (fn-for-low (rest low)))]))

;; Template rules used:
;;    - one of: 2 cases
;;    - atomic distinct: empty
;;    - compund (listof Widget)
;;    - self-reference: (rest low) is a (listof Widget)
;;    - referance: (first low) is a widget

;; +++++++ Abstract Function Template ++++++++++++++

#;
(define (fn-for-widget widget)
  (local [(define (fn-for-widget--element w) 
            (... (widget-name w) 
                 (widget-quantity w)
                 (widget-time w) 
                 (widget-price w) 
                 (fn-for-widget--low 
                  (widget-parts w))))
          (define (fn-for-widget--low low) 
            (cond [(empty? low) ...] 
                  [else 
                   (... fn-for-widget--element (first low) 
                        (fn-for-widget--low (rest low)))]))]
    (fn-for-widget--element widget)))

;; Template rules used:
;;    - Mutual Reucsion: (widget-parts w) is a (listof Widget)
;;                       (first low) is a Widget
;;    - fn-for-widget is
;;          - Compound: 4 fields
;;    - fn-for-widget--low is:
;;          - one of: 2 cases
;;          - atomic distinct: empty
;;          - compund (listof Widget)


;; ================
;; Constants

(define Wire (make-widget "Wire" 3 5 5 empty))
(define Cord (make-widget "Cord" 7 5 5 (list Wire)))
(define Numbers (make-widget "Numbers" 9 5 5 empty))
(define Buttons (make-widget "Buttons" 8 5 5 (list Numbers)))
(define Cell (make-widget "Cell" 6 25 7 (list Buttons)))
(define Receiver (make-widget "Receiver" 10 5 7 empty))
(define Telephone (make-widget "Telephone" 5 20 15 (list Receiver Buttons Cord)))

(define Glass (make-widget "Glass" 6 9 4 empty))
(define Beads (make-widget "Beads" 25 12 7 (list Glass)))
(define Bracelet (make-widget "Bracelet" 5 3 5 (list Beads)))
(define Chain (make-widget "Chain" 7 2 1 empty))
(define Pendant (make-widget "Pendant" 4 3 1 empty))
(define Necklace (make-widget "Necklace" 10 7 3 (list Chain Pendant)))
(define Rings (make-widget "Rings" 15 8 11 empty))
(define Jewelry (make-widget "Jewelry" 4 17 30 (list Rings Necklace Bracelet)))

;; ===============
;; Functions

;; ++++++++ Abstraction function for 1 - 3 +++++++++++

;; widget (widget -> boolean) -> (listof widget)
;; Given a widget and a filter function, this will return a list with all of the (sub)widgets that fit the filter

(check-expect (filter-widgets Wire (lambda (w) (> (string-length (widget-name w)) 5))) empty)
(check-expect (filter-widgets Chain (lambda (w) (< (widget-price w) 8))) (list Chain))
(check-expect (filter-widgets Cord (lambda (w) (< (widget-quantity w) 4))) (list Wire))
(check-expect (filter-widgets Jewelry (lambda (w) (> (string-length (widget-name w)) 5))) (list Jewelry Necklace Pendant Bracelet)) 

;; Template rules used: abtraction function for widget & (listof Widget)

(define (filter-widgets widget filter)
  (local [(define (filter-widget-list low)
            (cond [(empty? low) empty]
                  [else 
                   (append (filter-widget (first low))
                           (filter-widget-list (rest low)))]))
          (define (filter-widget w)
            (if (filter w)
                (cons w (filter-widget-list (widget-parts w)))
                (filter-widget-list (widget-parts w))))]
    (filter-widget widget)))

;; ++++++++ Part 1 Func 1 +++++++++++++
;; widget Natural -> (listof widget)
;; Given a widget and a length, this function will return all (sub)widgets whose name is longer than the length specified

(check-expect (find-widget-name-longer-than Wire 10) empty)
(check-expect (find-widget-name-longer-than Wire 2) (list Wire))
(check-expect (find-widget-name-longer-than Cord 3) (list Cord Wire))
(check-expect (find-widget-name-longer-than Cell 5) (list Buttons Numbers))
(check-expect (find-widget-name-longer-than Jewelry 5) (list Jewelry Necklace Pendant Bracelet))

(define (find-widget-name-longer-than w len)
  (filter-widgets w (lambda (w) (> (string-length (widget-name w)) len))))

;; +++++++ Part 1 Func 2 ++++++++++++

;; widget Natural -> (listof widget)
;; Given a widget and an amount, will return all (sub)widgets whose quantity is less than the amount

(check-expect (find-widget-quantity-over Wire 5) empty)
(check-expect (find-widget-quantity-over Jewelry 5) (list Rings Necklace Chain Beads Glass))
(check-expect (find-widget-quantity-over Chain 5) (list Chain))
(check-expect (find-widget-quantity-over Beads 5) (list Beads Glass))

(define (find-widget-quantity-over w qty)
  (filter-widgets w (lambda (w) (> (widget-quantity w) qty))))

;; +++++++ Part 1 Func 3 ++++++++++++

;; widget Natural -> (listof widget)
;; Takes in a widget and an amount, will returns all (sub)widgets whose price is less than the amount

(check-expect (find-widget-cheaper-than Wire 5) empty)
(check-expect (find-widget-cheaper-than Jewelry 5) (list Necklace Chain Pendant Glass))
(check-expect (find-widget-cheaper-than Chain 8) (list Chain))
(check-expect (find-widget-cheaper-than Beads 12) (list Beads Glass))

(define (find-widget-cheaper-than w price)
  (filter-widgets w (lambda (w) (< (widget-price w) price))))

;; ++++++++++++ Abstraction function for 4 +++++++++++++

;; widget (widget -> boolean) -> (listof widget)
;; Given a widget and a comparision function, will return a (listof widget) of the subwidgets of the
;;    inputted widget where each subwidget has at least one subwidget who fits the comparision function

(check-expect (dependent-filter
               Wire
               (lambda (x) (< (widget-quantity x) 5))) empty)
(check-expect (dependent-filter
               Cell
               (lambda (x) (> (widget-quantity x) 2))) (list Buttons))
(check-expect (dependent-filter
               Jewelry
               (lambda (x) (< (widget-price x) 10))) (list Necklace Bracelet Beads))
(check-expect (dependent-filter
               Jewelry
               (lambda (x) (> (widget-price x) 1))) (list Bracelet Beads))

;; Template rules used: abtraction function for widget & (listof Widget)

(define (dependent-filter wid fn)
  (local [(define (n-list--e w)
            (cond [(subs-hard-to-make?--loe (widget-parts w)) (cons w (n-list--loe (widget-parts w)))]
                  [else
                   (n-list--loe (widget-parts w))]))
          (define (n-list--loe loe)
            (cond [(empty? loe) empty]
                  [else
                   (append (n-list--e (first loe)) (n-list--loe (rest loe)))]))
          (define (subs-hard-to-make? w)
            (cond [(empty? (widget-parts w)) (fn w)]
                  [else
                   (subs-hard-to-make?--loe (widget-parts w))]))
          (define (subs-hard-to-make?--loe low)
            (cond [(empty? low) false]
                  [else
                   (or (subs-hard-to-make? (first low)) (subs-hard-to-make?--loe (rest low) ))]))]
    (n-list--loe (widget-parts wid))))
          

;; +++++++ Part 1 Func 4 ++++++++++++

;; Widget natural -> (listof Widget)
;; Given a widget and a cutoff, will return all subwidgets who have >= one subwidget whose quanity is less than the cutoff

(check-expect (find-widget-hard-make Wire 5) empty)
(check-expect (find-widget-hard-make Wire 1) empty)
(check-expect (find-widget-hard-make Cord 5) empty)
(check-expect (find-widget-hard-make Cell 10) (list Buttons))
(check-expect (find-widget-hard-make Jewelry 5) (list  Necklace))
(check-expect (find-widget-hard-make Jewelry 10) (list  Necklace Bracelet Beads))

(define (find-widget-hard-make w cutoff)
  (dependent-filter w (lambda (w) (< (widget-quantity w) cutoff))))


;; +++++++++++++ Abstraction Function for 5 ++++++++++++++

;; widget (widget -> boolean) -> widget | false
;; Given widget an a comparision function, searches the widget and subwidgest and will return
;;   widget that returns true for the comparision function. Else, returns false

(check-expect (search-widget Wire (lambda (x) (string=? (widget-name x) "Gregor"))) false)
(check-expect (search-widget Wire (lambda (x) (string=? (widget-name x) "Wire"))) Wire)
(check-expect (search-widget Telephone (lambda (x) (= (widget-quantity x) 9))) Numbers)

;; Template rules used: abtraction function for widget & (listof Widget)

(define (search-widget widg fn)
  (local [(define (find-widget widget)
            (if (fn widget) 
            widget
            (find-low (widget-parts widget))))
          (define (find-low low) 
            (cond [(empty? low) false]
                  [else 
                   (if (false? (find-widget (first low)))
                       (find-low (rest low))
                       (find-widget (first low)))]))]
    (find-widget widg)))

;; +++++++ Part 1 Func 5 +++++++++++

;; widget string -> widget | false
;; given widget and a name, searches the widget and all corresponding parts and will return a 
;;   widget with the same name. Else, it returns false

(check-expect (find-widget-name Wire "Wire") Wire)
(check-expect (find-widget-name Cord "Wire") Wire)
(check-expect (find-widget-name Telephone "Necklace") false)
(check-expect (find-widget-name Cord "") false)

(define (find-widget-name w name)
  (local [(define search
            (filter-widgets w (lambda (w) (string=? (widget-name w) name))))]
    (if (empty? search)
        false
        (first search))))

;; +++++++++++++++ Abstraction functions for 6 -7 +++++++++++++++

;; X (X -> (listof X)) (X -> Y) -> (listof Y)
;; Function that will list all elements and subelements of a structure. The function is given an input of type X,
;;   a function which will get the list of subelements from X, and a data type selector function, which will 
;;   return the correct attribute of the function that should be included in the list.

(define rest-wid (lambda (x) (widget-parts x))) ; Get low from widget (useful for check-expects) 
(define name-widg (lambda (x) (widget-name x))) ; An abritary data selector (useful for check-expects)

(check-expect (list-all Beads rest-wid name-widg) (list (widget-name Beads) (widget-name Glass)))
(check-expect (list-all Jewelry rest-wid name-widg) (list "Jewelry" "Rings" "Necklace" "Chain" "Pendant" "Bracelet" "Beads" "Glass"))
(check-expect (list-all Chain rest-wid name-widg) (list "Chain"))
(check-expect (list-all Wire rest-wid name-widg) (list "Wire"))
(check-expect (list-all Wire rest-wid identity) (list Wire))
(check-expect (list-all Cord rest-wid identity) (list Cord Wire))

;; Template rules used: abtraction function for widget & (listof Widget)

(define (list-all input rest-of selector)
  (local [(define (list-all--element e) 
            (cons (selector e) (list-all--low (rest-of e))))
          (define (list-all--low loe) 
            (cond [(empty? loe) empty] 
                  [else 
                   (append (list-all--element (first loe)) 
                           (list-all--low (rest loe)))]))]

    (list-all--element input)))


;; +++++++ Part 1 Func 6 ++++++++++++
;; Widget -> (listof Widget)
;; Given the main widget, the function will return a list of the widget and all of the sub widgets required to
;;    manufacture it

(check-expect (list-all-widgets Wire) (list Wire))
(check-expect (list-all-widgets Cord) (list Cord Wire))

(define (list-all-widgets wid)
  (list-all
   wid
   (lambda (x)
     (widget-parts x))
   identity))


;; +++++++ Part 1 Func 7 ++++++++++++
;; widget -> (listof Widget)
;; Given a widget, will return the name of the widget and the subwidgets used to manufacture it

(check-expect (list-all-widget-names Beads) (list (widget-name Beads) (widget-name Glass)))
(check-expect (list-all-widget-names Jewelry) (list "Jewelry" "Rings" "Necklace" "Chain" "Pendant" "Bracelet" "Beads" "Glass"))
(check-expect (list-all-widget-names Chain) (list "Chain"))
(check-expect (list-all-widget-names Wire ) (list "Wire"))

(define (list-all-widget-names wid)
  (list-all
   wid
   (lambda (x)
     (widget-parts x))
   (lambda (x)
     (widget-name x))))


;; +++++++ Sort Function ++++++++++++
;; widget (X X -> boolean) -> (listof widget)
;; Given a widget, this function will sort the widget and all of it's associated sub widges based on the
;;    given comparision function

(check-expect (sort-widgets Wire (lambda (x y) (< (widget-quantity x) (widget-quantity y)))) (list Wire))
(check-expect (sort-widgets Cord (lambda (x y) (> (widget-quantity x) (widget-quantity y)))) (list Wire Cord))

(define (sort-widgets wid order)
  (local [(define (gen-list--e w)
            (cons w (gen-list--loe (widget-parts w))))
          (define (gen-list--loe loe)
            (cond [(empty? loe) empty]
                  [else
                   (append (gen-list--e (first loe)) (gen-list--loe (rest loe)))]))
          (define (sort-list loe)
            (cond [(empty? loe) empty]
                  [else
                   (local
                     [(define pivot (first loe))]
                     (append
                      (sort-list (find-elements order pivot (rest loe)))
                      (list pivot)
                      (sort-list (find-elements (lambda (x y) (not (order x y))) pivot (rest loe)))))]))
          (define (find-elements fn p loe)
            (cond [(empty? loe) empty]
                  [(fn p (first loe))
                   (cons (first loe) (find-elements fn p (rest loe)))]
                  [else
                   (find-elements fn p (rest loe))]))]

    (sort-list (gen-list--e wid))))

;; widget -> widget
;; Given a widget, this function will search all the widget and it's subwidgets and return the one with
;;     the longest name
;;
;; Due to the nature of the sort function, if two widgets have the same number of characters, the higher ranking
;;    widget will be chosen. IE, for cord & wire, cord will be the output, as it is ranked higher

(check-expect (longest-name Wire) Wire)
(check-expect (longest-name Telephone) Telephone)
(check-expect (longest-name Cord) Cord)

(define (longest-name wid)
  (first (sort-widgets
          wid
          (lambda (x y)
            (< (string-length (widget-name x)) (string-length (widget-name y)))))))