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
             MessageArchiveFilter,
             MessageCompose,
             MyCallQueue,
             ReceptionAltNames,
             ReceptionCalendar,
             ReceptionCommands,
             ReceptionEmailAddresses,
             ReceptionOpeningHours,
             ReceptionProduct,
             ReceptionSalesmen,
             ReceptionSelector}