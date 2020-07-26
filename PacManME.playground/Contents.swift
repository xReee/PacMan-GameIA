//
//  Playground feito para meu post do médium sobre Gameplaykit
//  por Renata Faria
//

import GameplayKit

class Fugindo: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Cacando.Type
    }
   override func didEnter(from previousState: GKState?) {
        print("O fantasma está fugindo")
    }
}

class Cacando: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Fugindo.Type || stateClass is Dispersando.Type
    }
    override func didEnter(from previousState: GKState?) {
        print("O fantasma está cacando")
    }
}

class Dispersando: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Cacando.Type
    }
    override func didEnter(from previousState: GKState?) {
        print("O fantasma está dispersando")
    }
}


// Meu fantasma herda de State Machine
class FantasmaStateMachine: GKStateMachine {
    
}

//No nosso jogo vamos implementar nosso fantasma:
class GameController {
    var fantasmaAzul: FantasmaStateMachine? // <-- Nossa máquina de estados
    var timerRodada = Timer() // <-- vai controlar os turnos
    var timerTurno = Timer() // <-- Tempo de caçar/dispersar
    var timerSuperPoder = Timer() // <-- Tempo de superPoder
    var pacmanPossuiSuperpoderes: Bool // <-- Booleano para
    
    init() {
        fantasmaAzul = FantasmaStateMachine(states: [Fugindo(), Cacando(), Dispersando()]) // <-- Inicializar com nossos estados
        pacmanPossuiSuperpoderes = false
    }
    func jogar() {
        timerRodada = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: novaRodada(_:))
        timerTurno = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: trocarTurno(_:))
        fantasmaAzul?.enter(Dispersando.self) // <- O jogo começa com eles se dispersando
    }
    
    func novaRodada(_ timer: Timer) {
        print("______________")
        print("Novo turno")
        let sorteDoPacman = Int.random(in: 0..<15)
        if sorteDoPacman == 2 {
            self.pacmanPossuiSuperpoderes = true
            fantasmaAzul?.enter(Fugindo.self) // <-- Pacman tem superpoderes
            timerTurno.invalidate() // desliga o timer de turnos, afinal ele não vai poder mudar de turno mesmo
            timerSuperPoder.invalidate() // desliga o timer caso ainda esteja ativo
            timerSuperPoder = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: tirarSuperpoder(_:))
        }
    }
    
    func trocarTurno(_ timer: Timer) {
        guard let _ = fantasmaAzul else { return } // vendo se nossa máquina não é nula
        if pacmanPossuiSuperpoderes { return } // se o pacman tem superpoderes, não podemos mudar de estado!
        
        // vamos tentar entrar em caçar. Lembra do isValidNextState?
        if fantasmaAzul!.enter(Cacando.self) == false {
            
            // Não deu certo, então vamos entrar em dipersar
            fantasmaAzul?.enter(Dispersando.self)
        }
    }
    func tirarSuperpoder(_ timer: Timer) {
        pacmanPossuiSuperpoderes = false
        fantasmaAzul?.enter(Cacando.self) // <-- Pacman não tem mais superpoderes
        
        //não podemos esquecer de atualizar a troca de turnos!
        timerTurno = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: trocarTurno(_:))
    }
}

let jogo = GameController()
jogo.jogar()
