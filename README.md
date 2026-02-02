# Accesso Negato

Gioco narrativo realizzato con **Godot 4**, basato su esplorazione, dialoghi e transizioni cinematografiche tra scene con gestione dinamica della musica.

---

## 🎮 Panoramica

Il progetto combina:

* Narrazione guidata da dialoghi
* Transizioni visive con dissolvenze e immagini intermedie
* Gestione musicale dinamica con fade‑in e fade‑out tra le scene
* Struttura a livelli (storia progressiva)

Il flusso principale è:

**Menu → Scena Dialogo Iniziale → Livello 1 → Livello 2 → Win Room**

---

## 🧠 Struttura delle Scene

| Scena                      | Descrizione                                          |
| -------------------------- | ---------------------------------------------------- |
| `Menu.tscn`                | Menu principale con musica iniziale                  |
| `transizione_dialogo.tscn` | Scena narrativa introduttiva con player e narratrice |
| `principale.tscn`          | Livello 1                                            |
| `livello2.tscn`            | Livello 2                                            |
| `win_room.tscn`            | Scena finale                                         |

---

## 🎵 Sistema Musica

Ogni scena principale contiene un nodo:

```
AudioStreamPlayer
└── Name: Music
```

⚠️ **Regole importanti**

* Il nodo **deve chiamarsi esattamente `Music`**
* **Autoplay disattivato**
* Lo stream audio va assegnato nella scena

La gestione della musica è centralizzata nello script:

```
Transizione.gd
```

Questo script:

1. Fa fade‑out della musica della scena corrente
2. Cambia scena con transizione visiva
3. Avvia la musica della nuova scena con fade‑in

---

## 🎬 Sistema Transizioni

Le transizioni tra scene non avvengono mai con `change_scene_to_file()` diretto.

Si usa sempre:

```
get_node("/root/Transizione").cambia_scena(path_scena)
```

La transizione include:

* Dissolvenza schermo
* Visualizzazione di un'immagine intermedia
* Eventuale monologo della narratrice
* Cambio scena
* Dissolvenza inversa

---

## 🗂 File Chiave

| File                        | Ruolo                                       |
| --------------------------- | ------------------------------------------- |
| `Transizione.tscn`          | Scena di transizione caricata come Autoload |
| `Transizione.gd`            | Gestione transizioni visive e audio         |
| `narratrice_transizione.gd` | Dialogo scena introduttiva                  |

---

## ⚙️ Autoload

In **Project → Project Settings → Autoload**:

| Nome          | Path                     |
| ------------- | ------------------------ |
| `Transizione` | `res://Transizione.tscn` |

---

## 🧩 Aggiungere un nuovo livello

1. Crea la scena (`livello3.tscn`)
2. Aggiungi un nodo `AudioStreamPlayer` chiamato `Music`
3. Assegna la traccia audio
4. Disattiva Autoplay
5. Usa:

```
Transizione.cambia_scena("res://livello3.tscn")
```

---

## 🛠 Problemi Comuni

| Problema            | Causa                              |
| ------------------- | ---------------------------------- |
| La musica non parte | Nodo non chiamato `Music`          |
| Parte senza fade    | Scena cambiata senza `Transizione` |
| Musica doppia       | Autoplay attivo                    |

---

## 👨‍💻 Tecnologie

* Godot Engine 4
* GDScript
* AudioStreamPlayer
* Tween per fade audio

---

## 📌 Note di Sviluppo

Le scene `.tscn` possono risultare modificate dopo un pull perché Godot riscrive automaticamente ID interni e metadati delle risorse.

---

**Progetto in sviluppo.**
