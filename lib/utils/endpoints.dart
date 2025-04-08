

const String apiLogin = '/api/v1/auth/login';
const String apiRefresh = '/api/v1/auth/refresh';

// Survey endpoints
const String epParticipant = '/Participant';



const String epResponseByParticipant = '/Response/personId/';
const String epResponse = '/Response';

const String epAnswers = '/ResponseAnswers';
const String epAnswersByResponse = '/ResponseAnswers/Response';

// Survey endpoints
const String epSurvey = '/Survey';

// Question endpoints

const String epQuestionBySurvey = '/Question/Survey';

// Answer Option endpoints

const String epAnswerOptionByQuestion = '/AnswerOption/Question';

const String epAnswerOption = '/AnswerOption';

// Helper methods for constructing URLs with parameters
String getByIdUrl(String base, String id) => '$base/$id';
String getDeleteUrl(String base, String id) => '$base/$id';
String getPageUrl(String base, int page) => '$base/$page';
String getPageSortUrl(
        String base, int page, String sortField, String direction) =>
    '$base/$page/Sort/$sortField/Direction/$direction';
