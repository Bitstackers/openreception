library enums;

enum AgentState {BUSY,
                 IDLE,
                 PAUSE,
                 UNKNOWN}

enum AlertState {OFF,
                 ON}

enum AppState {LOADING,
               ERROR,
               READY}

enum Cmd {EDIT,
          NEW,
          SAVE}

enum Context {Home,
              Homeplus,
              CalendarEdit,
              Messages}

enum Widget {AgentInfo,
             CalendarEditor,
             ContactCalendar,
             ContactData,
             ContactSelector,
             GlobalCallQueue,
             MessageCompose,
             MyCallQueue,
             ReceptionCalendar,
             ReceptionCommands,
             ReceptionOpeningHours,
             ReceptionProduct,
             ReceptionSalesmen,
             ReceptionSelector,
             ReceptionAltNames,
             MessageArchiveFilter}